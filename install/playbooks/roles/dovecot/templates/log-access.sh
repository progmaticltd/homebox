#!/bin/sh

# Post login script for Dovecot
# Blocking: Yes
# RunAsUser: Yes
# NeedDecryptKey: No

# If remote IP is 127.0.0.1, exit
# This is probably a webmail
# TODO: pass the IP address from the webmail

log_error() {
    echo "$@" 1>&2;
}

if [ "${IP}" = "127.0.0.1" ]; then
    exit 0
fi

if [ "${IP}" = "" ]; then
    log_error "No IP received for IP logging"
fi

# Initialise the environment
secdir="${HOME}/mails/security"
conlog="${secdir}/connections.log"
unixtime=$(date +%s)
day=$(date --rfc-3339=seconds | cut -f 1 -d ' ')
time=$(date --rfc-3339=seconds | cut -f 2 -d ' ')
hourmin=$(date --rfc-3339=seconds | cut -f 2 -d ' ' | cut -f 1,2 -d ':')

# Source should be always IMAP, unless when the webmail is used (roundcube or SOGo)
# Not implemented yet
source=imap

# Create the security directory for the user
test -d "${secdir}" || mkdir "${secdir}"

# Check if we already log this IP
ipSig=$(echo "${IP}" | md5sum | cut -f 1 -d ' ')
lockFile="${secdir}/${ipSig}.lock"

# Exit if we are currently logging this IP
test -f "${lockFile}" && exit 0

# Start processing
touch "${lockFile}"
sync "${lockFile}"

# Remove lockfile on exit
trap "rm -f ${lockFile}" EXIT

# Check if the GeoIP lookup binary is available
test -x /usr/bin/geoiplookup || exit 0

# Needed to ignore local IP addresses
test -x /usr/bin/ipcalc || exit 0

# Create the file if it not exists
test -f "${conlog}" || touch "${conlog}"

# Exit if I cannot create the log file
test -f "${conlog}" || exit 0

# Check if already logged in from this IP in the current hour
# TODO: Use unix time
count=$(grep "${IP}" "${conlog}" | grep -c "^${day} ${hourmin}")

# Already logged in from this IP in the last hour
if [ "${count}" != "0" ]; then
    exit 0
fi

# Check if this is a private IP address
isPrivate=$(ipcalc "$IP" | grep -c "Private Internet")
isIPv6=$(echo "$IP" | grep -c ":")

# Create a log line with the origin
if [ "${isPrivate}" = "1" ]; then
    countryCode='-'
    countryName='-'
elif [ "${isIPv6}" = "1" ]; then
    lookup=$(geoiplookup6 "$IP")
else
    lookup=$(geoiplookup "$IP")
fi

if [ "${isPrivate}" = "0" ]; then
    countryCode=$(echo "${lookup}" | sed -r 's/.*: ([A-Z]{2}),.*/\1/g')
    countryName=$(echo "${lookup}" | cut -f 2 -d , | sed 's/^ //' | sed 's/ /_/g')
fi

# Add the IP to the list, need validatation
echo "${day} ${time} ${unixtime} ${IP} ${countryCode} ${countryName} ${source} NEW" >> "${conlog}"
sync "${conlog}"

# End processing
rm -f "${lockFile}"
