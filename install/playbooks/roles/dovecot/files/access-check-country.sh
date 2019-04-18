#!/bin/sh

# Check if the connection is from a whitelisted country.

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAsUser: Yes
# NeedDecryptKey: No
# Description: Country policy checker

# Exit codes
CONTINUE=0
WARNING=1
DENIED=2
ERROR=3

# Used to log errors in syslog or mail.log
log_error() {
    echo "$@" 1>&2;
}

# Read the gloabal check access policy
globalConf='/etc/homebox/access-check.conf'
export $(grep -v '^#' "$globalConf" | xargs)

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="$HOME/.config/homebox"

# Read the user policy if specified
userConf="$secdir/access-check.conf"
if [ -r "$userConf" ]; then
    export $(grep -v '^#' "$userConf" | xargs)
fi

if [ "$COUNTRIES_TRUST_HOME" = "YES" ]; then
    # Get the current home country
    HOME_COUNTRY=$(grep 'COUNTRY_CODE' /etc/homebox/external-ip | cut -f 2 -d =)
else
    HOME_COUNTRY='--'
fi

# Check if the GeoIP lookup binary is available
test -x /usr/bin/geoiplookup || exit $ERROR

# Needed to detect local IP addresses
test -x /usr/bin/ipcalc || exit $ERROR

# Create the security directory for the user
test -d "$secdir" || mkdir "$secdir"

# Create a unique lock file name for this IP address
# Exit if a script already check this IP address
ipSig=$(echo "$IP" | md5sum | cut -f 1 -d ' ')
lockFile="$secdir/$ipSig.lock"
test -f "$lockFile" && exit $CONTINUE

# Start processing, but remove lockfile on exit
touch "$lockFile"
trap 'rm -f $lockFile' EXIT

# If this is a private IP address, pass the hand to
# the next scripts
isPrivate=$(ipcalc "$IP" | grep -c "Private Internet")
isIPv6=$(echo "$IP" | grep -c ":")

if [ "$isPrivate" = "1" ]; then
    exit $CONTINUE
fi

if [ "$isIPv6" = "1" ]; then
    lookup=$(geoiplookup6 "$IP")
else
    lookup=$(geoiplookup "$IP")
fi

# Check if the country is found or not
# Use XX when not found
notFound=$(echo "$lookup" | grep -c 'IP Address not found')

if [ "$notFound" = "1" ]; then
    countryCode="XX"
    countryName="unknown country"
else
    countryCode=$(echo "$lookup" | sed -r 's/.*: ([A-Z]{2}),.*/\1/g')
    countryName=$(echo "$lookup" | cut -f 2 -d , | sed 's/^ //')
fi

# If we trust the same country, just accept the connection
if [ "$HOME_COUNTRY" = "$countryCode" ] && [ "$COUNTRIES_TRUST_HOME" = "YES" ]; then
    exit $CONTINUE
fi

# Check if the country is trusted
trustedCountry=$(echo "$COUNTRIES_TRUST" | grep -c -E "(^|,)$countryCode(,|$)")
if [ "$trustedCountry" = "1" ]; then
    # If we trust the country we are in, just accept the connection
    exit $CONTINUE
fi


if [ "$UNUSUAL" = "warn" ]; then
    printf "* OK [ALERT] Accepted a connection from %s (IP=%s)\r\n" "$countryName" "$IP"
    exit $WARNING
else
    # Refuse the connection or send a warning to the user
    printf "* NO [ALERT] Connection from %s not accepted\r\n" "$countryName"
    exit $DENIED
fi

