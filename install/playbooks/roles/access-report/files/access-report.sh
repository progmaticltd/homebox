#!/bin/sh

# Send a monthly report to the user
MAIL=$1
USER=$(expr "$MAIL" : '\([a-z]*\)')
HOME="/home/users/$USER"
domain=$(echo "$MAIL" | cut -f 2 -d '@')

# Initialise the variables
secdir="$HOME/security"
connLogFile="$secdir/imap-connections.db"
lastMonth=$(date -d '1 month ago' +'%Y-%m')
lastMonthText=$(date -d '1 month ago' +'%B %Y')
style="table {border: 1px solid #ddd} tr:nth-child(odd) {background: #ddd} th {padding: 0 1ch}"
report="<html><head><style>$style</style></head><body>"

# Maximum height of the per hour graph in pixels
maxHeight=200

# Create the per country report
condition="unixtime like '$lastMonth-%' and countryName != '-' and countryCode != 'XX'"
query="select count(distinct(countryName)) from connections where $condition"
nbCountry=$(sqlite3 "$connLogFile" "$query")

# How we display the time columns
timeColumns="strftime('%d', min(unixtime)) as startTime,strftime('%d', max(unixtime))"

if [ "0$nbCountry" -ge "1" ]; then
    fields="$timeColumns,countryName,count(*) as count"
    group="group by countryName"
    order="order by startTime"
    countryQuery="select $fields from connections where $condition $group $order;"
    countryReport=$(sqlite3 -html "$connLogFile" "$countryQuery")
    title="<h2>Per country</h2>"
    headers="<table><th>From</th><th>Until</th><th>Country</th><th>Count</th>"
    footer="</table>"
    report="$report $title $headers $countryReport $footer"
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
    headers="<table><th>From</th><th>Until</th><th>IP Address</th><th>Count</th>"
    footer="</table>"
    report="$report $title $headers $addressReport $footer"
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
    headers="<table><th>From</th><th>Until</th><th>IP Address</th><th>Count</th>"
    footer="</table>"
    report="$report $title $headers $addressReport $footer"
fi

# per client (SOGo/Roundcube/IMAP)
condition="unixtime like '$lastMonth-%' and countryName = '-'"
query="select count(distinct(ip)) from connections where $condition"
nbSource=$(sqlite3 "$connLogFile" "$query")

if [ "0$nbSource" -ge "1" ]; then
    fields="strftime('%d', unixtime) as day, strftime('%H:%m',min(unixtime)),strftime('%H:%m',max(unixtime)), source"
    group="group by source, day"
    order="order by day"
    sourceQuery="select $fields from connections where $condition $group $order;"
    sourceReport=$(sqlite3 -html "$connLogFile" "$sourceQuery")
    title="<h2>Client</h2>"
    headers="<table><th>Day</th><th>From</th><th>Until</th><th>Client</th>"
    footer="</table>"
    report="$report $title $headers $sourceReport $footer"
fi

# per time of the day
condition="unixtime like '$lastMonth-%'"
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
        height=$((maxHeight * count / maxHours))
        barStyle="height:$height;background:#bbb;margin:0;"
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

# Make sure it is properly displayed in standard mail systems
contentHeader='Content-Type: text/html; charset="ISO-8859-1"'
alertHeader="X-Postmaster-Alert: Montly report"

# Prepare the email headers
subject="Monthly report ($lastMonthText)"
from="postmaster@${domain}"

# Close the report
report="$report</body></html>"

# Send the email
echo "$report" | mail -a "$contentHeader" -a "$alertHeader" -r "$from" -s "$subject" "$MAIL"

