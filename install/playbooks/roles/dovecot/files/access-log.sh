#!/bin/dash

# Log various information on every IMAP connection
# This is using geoip free databases.
# The file is an sqlite3 database belonging to the user, located at
#   /home/users/<user>/mails/security/imap-connections.db
# Informations logged:
#   - IP address
#   - time
#   - unixtime
#   - IP
#   - country code
#   - Country
#   - ISP (Internet Service provider)
#   - source (SOGo / Roundcube / imap)
#   - status (OK / WARNING / DENIED)
#   - score (a high score means the connection is warned or denied)
#   - details (why the connection has been warned or denied)
#
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
# RunAs: User
# NeedDecryptKey: No
# ManageLAN: Yes
# Reporting: Yes

# Exit codes
CONTINUE=0

# Used to log errors in syslog or mail.log
log_error() {
    echo "$@" 1>&2;
}

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="$HOME/security"

# Create the security directory for the user
test -d "$secdir" || mkdir -m 700 "$secdir"

# Create a unique lock file name for this IP address and source
ipSig=$(echo "$IP:$SOURCE" | md5sum | cut -f 1 -d ' ')
lockFile="$secdir/$ipSig.lock"
test -f "$lockFile" && exit $CONTINUE

# Start processing, but remove lockfile on exit
touch "$lockFile"
trap 'rm -f $lockFile' EXIT

# The file that will contains the connection logs
connLogFile="$secdir/imap-connections.db"

# Chekc if the connections log database exist
if [ ! -f "$connLogFile" ]; then
    logger -p user.warning "Database for user $USER not found"
    exit $CONTINUE
fi

# Check if already logged in from this IP in the last minute
isoLastMinute=$(date -d '1 min ago' --rfc-3339=seconds | sed 's/+.*//')
condition="unixtime >= '$isoLastMinute' AND source='$SOURCE' AND ip='$IP'"
query="select count(*) from connections where $condition"

count=$(sqlite3 -batch "$connLogFile" "$query")

# Check if already connected from this IP in the last minute, then exit safely
if [ "0$count" -gt "0" ]; then
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
    countryName=$(echo "$lookup" | cut -f 2 -d , | sed 's/^ //')
fi

# Remove the new lines from the details before storing them in the database
smallDetails=$(echo "$DETAILS" | tr '\n' ';' | sed -r 's/(^;|;$)//g')

# Get the Internet Service Provider from http://ip-api.com/
# The limit is 150 requests per minute from an IP address.
# This is particularly useful if you are using only ISP,
# regardless of the IP address
isp='unknown'

if [ "$isPrivate" = "1" ]; then
    isp='private'
elif [ "$ALLOW_EXTERNAL_QUERIES" = "YES" ]; then
    # set curl options
    # -s: silent
    # -f: fail silently, return an empty string on failure
    # -m 10: wait maximum 10 seconds for the whole process
    url="http://ip-api.com/line/$IP?fields=isp"
    isp=$(curl -s -f -m 10 "$url" | sed "s/'/''/g")
fi

if [ "$isp" = "" ]; then
    isp='unknown'
fi

# Prepare the query, and insert the connection record
columns='ip, countryCode, countryName, provider, source, status, score, details'
values="'$IP','$countryCode','$countryName','$isp', '$SOURCE','$STATUS', '$SCORE','$smallDetails'"
command="insert into connections ($columns) VALUES ($values);"

sqlite3 -batch "$connLogFile" "$command"

# While we are here, let's do some cleanup and keep one year only
isoLastYear=$(date -d '1 year ago' --rfc-3339=seconds | sed 's/+.*//')
query="delete from connections where unixtime <= '$isoLastYear'"
sqlite3 -batch "$connLogFile" "$query"
