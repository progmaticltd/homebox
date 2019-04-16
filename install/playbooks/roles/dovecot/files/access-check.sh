#!/bin/sh

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
#   - accept or not (OK/NOK)
#   - reason
#   2019-04-15 20:24:25+01:00 1555356265 92.40.248.238 GB United_Kingdom imap OK trusted_ip
# When the country is not found, we use XX and "Neverland"
# The last field is used to check if a connection from this IP address has been done before.
# Possible implementations:
# - When the connection is new, the script can act differently, according to the user settings
# - An alert is sent by XMPP when a new IP address or country is used
# - Each user can set acceptable countries to connect from
# - A simple TFA can be provided from new IP addresses, using for instance google-authenticator and xmpp
# - Monthly reports per country, time, etc.

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAsUser: Yes
# NeedDecryptKey: No

# Exit codes
CONTINUE=0
WARNING=1
DENIED=2
ERROR=3

# Used to log errors in syslog or mail.log
log_error() {
    echo "$@" 1>&2;
}

# If remote IP is 127.0.0.1, exit
# This is probably a webmail
# There is an attempt from the parent script
# to guess the real IP address , although
# it can be wrong for sites with a lot of
# email users, it should be enough for a family
# or small community
if [ "$IP" = "127.0.0.1" ]; then
    log_error "Loopback IP address for IMAP connection"
    printf "* NO [ALERT] IMAP connection from loopback not allowed (user='$USER')\r\n"
    exit $DENIED
fi

if [ "$IP" = "" ]; then
    log_error "No IP received for IP logging"
    printf "* NO [ALERT] An IP address is needed to connect (user='$USER')\r\n"
    exit $DENIED
fi

# Read the gloabal check access policy
globalConf='/etc/dovecot/access-check.conf'
export $(cat "$globalConf" | grep -v '^#' | xargs)

# Security directory
secdir="$HOME/mails/security"

# Read the user policy if specified
userConf="$secdir/access-check.conf"
if [ -r "$userConf" ]; then
    export $(cat "$userConf" | grep -v '^#' | xargs)
fi

# Display parsed policies
if [ "$DEBUG" = "YES" ]; then
  log_error "Unusual behaviour: $UNUSUAL"
  log_error "Nb of days to trust a new connection: $DAYS_TRUST"
  log_error "Trusted countries: $COUNTRIES_TRUST"
  log_error "Trust home country: $COUNTRIES_TRUST_HOME"
  log_error "Trusted IPs: $IPS_TRUST"
  log_error "Trust home / lan: $IPS_TRUST_HOME"
fi

# Get the current home country
HOME_COUNTRY=$(grep 'COUNTRY_CODE' /etc/homebox/external-ip | cut -f 2 -d =)

# Initialise the environment
unixtime=$(date +%s)
lastMinute=$(expr $unixtime - 60)
trustPeriod=$(expr $unixtime - 86400 \* $DAYS_TRUST)
day=$(date --rfc-3339=seconds | cut -f 1 -d ' ')
time=$(date --rfc-3339=seconds | cut -f 2 -d ' ')

# Check if the GeoIP lookup binary is available
test -x /usr/bin/geoiplookup || exit $ERROR

# Needed to detect local IP addresses
test -x /usr/bin/ipcalc || exit $ERROR

# Create the security directory for the user
test -d "$secdir" || mkdir "$secdir"

# Check if we already log this IP
ipSig=$(echo "$IP" | md5sum | cut -f 1 -d ' ')
lockFile="$secdir/$ipSig.lock"
test -f "$lockFile" && exit 'OK'

# Start processing
touch "$lockFile"

# The file that will contains the connection logs
connLogFile="$secdir/connections.log"

# The file that will contains error messages
warningsFile="$secdir/warnings.log"

# Remove lockfile on exit
trap "rm -f $lockFile" EXIT

# Create the file if it not exists
test -f "$connLogFile" || touch "$connLogFile"

# Exit if I cannot create the log file
test -f "$connLogFile" || exit $ERROR

# Check if already logged in from this IP in the last minute
# Get the last connection from this IP
lastConnFromThisIP=$(grep "$IP.* OK " "$connLogFile" | tail -n1 | cut -f 3 -d ' ')

# Check if already connected from this IP in the last minute, then exit safely
if [ "0$lastConnFromThisIP" -gt "0$lastMinute" ]; then
    exit $CONTINUE
fi

# The last two fields
status='NOK'
reason='unknown_ip'

# Check if already connected from this IP in the last week / month / etc
if [ "0$lastConnFromThisIP" -gt "0$trustPeriod" ]; then
    status='OK'
    reason='trusted_ip'
else
    # The default reason to warn or reject the connection is an untrusted IP
    reason='untrusted_ip'
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

trustedCountry=$(echo "$COUNTRIES_TRUST" | grep -c -E "(^|,)$countryCode(,|$)")
trustedIP=$(echo "$IPS_TRUST" | grep -c -E "(^|,)$IP(,|$)")

# If we trust the same country, just accept the connection
if [ "$HOME_COUNTRY" = "$countryCode" ] && [ "$COUNTRIES_TRUST_HOME" = "YES" ]; then
    status='OK'
    reason='home_country'
elif [ "$isPrivate" = "1" ] && [ "$IPS_TRUST_HOME" = "YES" ]; then
    # If we trust the LAN / home network, just accept the connection
    status='OK'
    reason='home_network'
elif [ "$trustedCountry" = "1" ]; then
    # If we trust the country we are in, just accept the connection
    status='OK'
    reason='trusted_country'
elif [ "$trustedIP" = "1" ]; then
    # If we trust the IP are in, just accept the connection
    status='OK'
    reason='trusted_ip'
fi

# Add the IP to the list, need validatation
echo "$day $time $unixtime $IP $countryCode $countryName $SOURCE $status $reason" >>"$connLogFile"

if [ "$status" != "OK" ]; then
    printf "* NO [ALERT] This IP address is not trusted yet ('$IP' / $countryName )\r\n"
    exit $DENIED
fi

# Return the specified status code
exit $CONTINUE
