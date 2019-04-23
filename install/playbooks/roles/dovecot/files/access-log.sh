#!/bin/dash

# Log the IP addresses, the country and the client type on every connection
# The client type can be Roudncube, SOGo or IMAP
# This is using geoip free databases.
# The lines are going to this file:
#   /home/users/<user>/mails/security/connections.log
# Each line is as follow:
#   - date
#   - time
#   - unixtime
#   - IP
#   - country code
#   - Country
#   - source (SOGo / Roundcube / imap)
#   - status (OK / WARNING / DENIED)
#   - details (why the connection has been blocked or warned)
# Examples:
#   2019-04-15 20:24:25+01:00 1555356265 92.40.248.238 GB United_Kingdom Roundcube OK
#   2019-04-17 18:53:42+00:00 1555527222 199.249.230.112 US United_States imap DENIED \
#                             Access denied by Country policy checker
# When the country is not found, we use XX and "Neverland"
# The last field is used to check if a connection from this IP address has been done before.
# Possible implementations:
# - When the connection is new, the script can act differently, according to the user settings
# - An alert is sent by XMPP when a new IP address or country is used
# - Each user can set acceptable countries to connect from
# - A simple TFA can be provided from new IP addresses, using for instance google-authenticator and xmpp
# - Monthly reports per country, time, etc.

# Post login script for Dovecot, this block is parsed by the parent script
# Blocking: No
# RunAsUser: Yes
# NeedDecryptKey: No
# AlwaysRun: Yes

# Exit codes
CONTINUE=0
ERROR=3

# Used to log errors in syslog or mail.log
log_error() {
    echo "$@" 1>&2;
}

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="$HOME/security"

# Initialise the environment
unixtime=$(date +%s)
lastMinute=$((unixtime - 60))
day=$(date --rfc-3339=seconds | cut -f 1 -d ' ')
time=$(date --rfc-3339=seconds | cut -f 2 -d ' ')

# Create the security directory for the user
test -d "$secdir" || mkdir -m 700 "$secdir"

# Create a unique lock file name for this IP address
ipSig=$(echo "$IP" | md5sum | cut -f 1 -d ' ')
lockFile="$secdir/$ipSig.lock"
test -f "$lockFile" && exit $CONTINUE

# Start processing, but remove lockfile on exit
touch "$lockFile"
trap 'rm -f $lockFile' EXIT

# The file that will contains the connection logs
connLogFile="$secdir/imap-connections.log"

# Create the file if it not exists
test -f "$connLogFile" || touch "$connLogFile"

# Exit if I cannot create the log file
test -f "$connLogFile" || exit $ERROR

# Check if already logged in from this IP in the last minute
# Get the last connection from this IP
lastConnFromThisIP=$(grep "\\<$IP\\>.*\\<$SOURCE\\>" "$connLogFile" | tail -n1 | cut -f 3 -d ' ')

# Check if already connected from this IP in the last minute, then exit safely
if [ "0$lastConnFromThisIP" -gt "0$lastMinute" ]; then
    exit $CONTINUE
fi

# Check if this is a private IP address
isPrivate=$(ipcalc "$IP" | grep -c "Private Internet")
isIPv6=$(echo "$IP" | grep -c ":")

# Create a log line with the origin
if [ "$isPrivate" = "1" ]; then
    countryCode='-'
    countryName='-'
    lookup=''
elif [ "$isIPv6" = "1" ]; then
    lookup=$(geoiplookup6 "$IP")
else
    lookup=$(geoiplookup "$IP")
fi

# Check if the country is found or not
notFound=$(echo "$lookup" | grep -c 'IP Address not found')

if [ "$notFound" = "1" ]; then
    # Country not found, use Neverland ;-)
    countryCode="XX"
    countryName="Neverland"
elif [ "$isPrivate" = "0" ]; then
    countryCode=$(echo "$lookup" | sed -r 's/.*: ([A-Z]{2}),.*/\1/g')
    countryName=$(echo "$lookup" | cut -f 2 -d , | sed 's/^ //' | sed 's/ /_/g')
fi

# Add the IP to the list, need validatation
echo "$day $time $unixtime $IP $countryCode $countryName $SOURCE $STATUS $DETAILS" >>"$connLogFile"
