#!/bin/sh

# Description: send a monthly report to the user with the IMAP events
# Parameter 1: name of the user

# The report contains:
# - Connections per country
# - Unknown countries
# - Warned and denied connections
# - Local access
# - Client statustics (Roundcube / SOGo / IMAP)
# - Statistics per hour of the day

# This script is very simple and probably perfectible,
# for instance by using Python.
# TODO: Multilingual and template HTML file


# Read the domain name from postfix configuration
domain=$(grep ^myorigin /etc/postfix/main.cf | sed 's/myorigin = //')

buildAndSendReport() {

    user=$1
    
    if [ "$user" = "" ]; then
        return
    fi
    
    if [ ! -d "/home/users/$user" ]; then
        logger -p user.warning "Home folder not found for user '$user'"
        return
    fi
    
    # Initialise the variables and database file
    mail="$user@$domain"
    home="/home/users/$user"
    secdir="$home/security"
    connLogFile="$secdir/imap-connections.db"
    sendReport=0
    
    if [ ! -r "$connLogFile" ]; then
        logger -p user.warning "Cannot read connections database file '$connLogFile'"
        return
    fi

    # Common variables
    lastMonth=$(date -d '1 month ago' +'%Y-%m')
    lastMonthText=$(date -d '1 month ago' +'%B %Y')
    style="table {border: 1px solid #ddd} tr:nth-child(odd) {background: #eee} th {padding: 0 1ch}"
    report="<html><head><style>$style</style></head><body>"

    # Add report title, especially when the report is not sent to the original user
    report="$report<h1>Monthly report for $user ($mail)</h1>"
    
    # Maximum height of the per hour graph in pixels
    hourGraphHeight=200
    
    # Create the per IP address report
    condition="unixtime like '$lastMonth-%'"
    query="select count(*) from connections where $condition"
    nbAddresses=$(sqlite3 "$connLogFile" "$query")
    
    # How we display the time columns
    timeColumns="strftime('%d', min(unixtime)) as startTime,strftime('%H:%M:%S', min(unixtime))"
    timeColumns="$timeColumns, strftime('%d', max(unixtime)),strftime('%H:%M:%S', max(unixtime))"
    
    if [ "0$nbAddresses" -ge "1" ]; then
        fields="ip,$timeColumns,countryName,count(*) as count"
        group="group by ip"
        order="order by count desc"
        addressQuery="select $fields from connections where $condition $group $order;"
        addressReport=$(sqlite3 -html "$connLogFile" "$addressQuery")
        title="<h2>Per IP address</h2>"
        headers="<table><th>IP address</th><th colspan='2'>From</th><th colspan='2'>Until</th><th>Country</th><th>Count</th>"
        footer="</table>"
        report="$report $title $headers $addressReport $footer"
        sendReport=1
    fi
    
    # Create the per country report
    condition="unixtime like '$lastMonth-%' and countryName != '-' and countryCode != 'XX'"
    query="select count(distinct(countryName)) from connections where $condition"
    nbCountry=$(sqlite3 "$connLogFile" "$query")
    
    # How we display the time columns
    timeColumns="strftime('%d', min(unixtime)) as startTime,strftime('%H:%M:%S', min(unixtime))"
    timeColumns="$timeColumns, strftime('%d', max(unixtime)),strftime('%H:%M:%S', max(unixtime))"
    
    if [ "0$nbCountry" -ge "1" ]; then
        fields="$timeColumns,countryName,count(*) as count"
        group="group by countryName"
        order="order by startTime"
        countryQuery="select $fields from connections where $condition $group $order;"
        countryReport=$(sqlite3 -html "$connLogFile" "$countryQuery")
        title="<h2>Per country</h2>"
        headers="<table><th colspan='2'>From</th><th colspan='2'>Until</th><th>Country</th><th>Count</th>"
        footer="</table>"
        report="$report $title $headers $countryReport $footer"
        sendReport=1
    fi
    
    # Unidentified IP addresses
    condition="unixtime like '$lastMonth-%' and countryCode = 'XX'"
    query="select count(distinct(ip)) from connections where $condition"
    nbAddress=$(sqlite3 "$connLogFile" "$query")
    
    if [ "0$nbAddress" -ge "1" ]; then
        fields="$timeColumns,ip,count(*) as count"
        group="group by ip"
        order="order by count desc"
        addressQuery="select $fields from connections where $condition $group $order;"
        addressReport=$(sqlite3 -html "$connLogFile" "$addressQuery")
        title="<h2>Unknown countries</h2>"
        headers="<table><th colspan='2'>From</th><th colspan='2'>Until</th><th>IP Address</th><th>Count</th>"
        footer="</table>"
        report="$report $title $headers $addressReport $footer"
        sendReport=1
    fi
    
    # Warned and denied connections
    condition="unixtime like '$lastMonth-%' and status != 'OK'"
    query="select count(distinct(ip)) from connections where $condition"
    nbError=$(sqlite3 "$connLogFile" "$query")
    
    if [ "0$nbError" -ge "1" ]; then
        fields="strftime('%d', unixtime), strftime('%H:%M:%S', unixtime),ip,countryName,source,lower(status),details"
        order="order by unixtime"
        errorQuery="select $fields from connections where $condition $order;"
        errorReport=$(sqlite3 -html "$connLogFile" "$errorQuery")
        title="<h2>Warned and denied connections</h2>"
        headers="<table><th>Day</th><th>Time</th><th>IP</th><th>Country</th><th>Source</th><th>Status</th><th>Details</th>"
        footer="</table>"
        report="$report $title $headers $errorReport $footer"
        sendReport=1
    fi
    
    # Create the per local IP report
    condition="unixtime like '$lastMonth-%' and countryName = '-'"
    query="select count(distinct(ip)) from connections where $condition"
    nbAddress=$(sqlite3 "$connLogFile" "$query")
    
    if [ "0$nbAddress" -ge "1" ]; then
        fields="$timeColumns,ip,count(*) as count"
        group="group by ip"
        order="order by count desc"
        addressQuery="select $fields from connections where $condition $group $order;"
        addressReport=$(sqlite3 -html "$connLogFile" "$addressQuery")
        title="<h2>Local access</h2>"
        headers="<table><th colspan='2'>From</th><th colspan='2'>Until</th><th>IP Address</th><th>Count</th>"
        footer="</table>"
        report="$report $title $headers $addressReport $footer"
        sendReport=1
    fi
    
    # per client (SOGo/Roundcube/IMAP)
    condition="unixtime like '$lastMonth-%'"
    query="select count(distinct(ip)) from connections where $condition"
    nbSource=$(sqlite3 "$connLogFile" "$query")
    
    if [ "0$nbSource" -ge "1" ]; then
        fields="source,strftime('%d', unixtime), strftime('%d',max(unixtime))"
        group="group by source"
        order="order by source"
        sourceQuery="select $fields from connections where $condition $group $order;"
        sourceReport=$(sqlite3 -html "$connLogFile" "$sourceQuery")
        title="<h2>Client</h2>"
        headers="<table><th>Client</th><th>From</th><th>Until</th>"
        footer="</table>"
        report="$report $title $headers $sourceReport $footer"
        sendReport=1
    fi
    
    # per time of the day
    condition="unixtime like '$lastMonth-%'"
    query="select count(*) from connections where $condition"
    nbConnections=$(sqlite3 "$connLogFile" "$query")
    
    if [ "0$nbConnections" -ge "1" ]; then

        fields="strftime('%H', unixtime) as hour,count(*) as count"
        group="group by hour"
        order="order by hour"
        hourQuery="select $fields from connections where $condition $group $order;"
        hourReport=$(sqlite3 "$connLogFile" "$hourQuery")
        title="<h2>Per hour</h2>"
        graph="<table><tr>"
        
        # Get the maximum number of connections per hour
        maxQuery="select $fields from connections where $condition $group order by count desc limit 1"
        maxHours=$(sqlite3 "$connLogFile" "$maxQuery" | cut -f 2 -d '|')
        
        for hour in $(seq -s ' ' -w 0 23); do
            count=$(echo "$hourReport" | grep  "^$hour|" | cut -f 2 -d '|')
            tdStyle="width:3ch;vertical-align:bottom;"
        
            if [ "$count" = "" ]; then
                cell="<td style='$tdStyle'></td>"
            else
                # convert to X pixels height max
                height=$((hourGraphHeight * count / maxHours))
                barStyle="height:$height;background:#bbc;margin:0;"
                bar="<div style='$barStyle'>&nbsp;</div>"
                cell="  <td style='$tdStyle'>$bar</td>\n"
            fi
            graph="$graph$cell"
        done
        graph="$graph</tr><tr>"
        
        for hour in $(seq -s ' ' -w 0 23); do
            bar="<th>$hour</th>"
            graph="$graph $bar"
        done
        
        graph="$graph</tr></table>"
        
        report="$report $title $graph"

        # the report is not empty
        sendReport=1
    fi
    
    if [ "$sendReport" = "1" ]; then

        # Make sure it is properly displayed in standard mail systems
        contentHeader='Content-Type: text/html; charset="ISO-8859-1"'
        alertHeader="X-Postmaster-Alert: Montly report"
        
        # Prepare the email headers
        subject="Monthly report ($user, $lastMonthText)"
        from="postmaster@${domain}"
        
        # Close the report
        report="$report</body></html>"
        
        # Send the email
        echo "$report" | mail -a "$contentHeader" -a "$alertHeader" -r "$from" -s "$subject" "$mail"
    fi
}

# Get the list of users from LDAP
users=$(getent passwd -s ldap | cut -f 1 -d : | tr '\n' ' ')

# Build and send the report to each user
for user in $users; do
    buildAndSendReport "$user"
done
