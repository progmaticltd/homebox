#!/bin/dash

# Check if the connection is from a whitelisted country.

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAsUser: Yes
# NeedDecryptKey: No
# Score: Malus
# Description: Country policy checker

# Exit codes
TRUST=0
NEW_COUNTRY=128
UNKNOWN_COUNTRY=250

# When an error occurs, refuse the connection
ERROR=255

# Used to log errors in syslog or mail.log
log_error() {
    echo "$@" 1>&2;
}

# Read the gloabal check access policy
globalConf='/etc/homebox/access-check.conf'

# Read global configuration
# shellcheck disable=SC1090
. "$globalConf"

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="$HOME/.config/homebox"

# Read the user policy if it has been customised
userConf="$secdir/access-check.conf"

CUSTOM_COUNTRIES_TRUST=$(grep -c '^COUNTRIES_TRUST=' "$userConf")
CUSTOM_COUNTRIES_TRUST_HOME=$(grep -c '^COUNTRIES_TRUST_HOME=' "$userConf")

if [ "$CUSTOM_COUNTRIES_TRUST" = 1 ]; then
    COUNTRIES_TRUST=$(grep '^COUNTRIES_TRUST=' "$userConf" | cut -f 2 -d = | sed "s/'//g")
    logger "Using custom value for user $USER for trusted countries: $COUNTRIES_TRUST"
fi

if [ "$CUSTOM_COUNTRIES_TRUST_HOME" = 1 ]; then
    COUNTRIES_TRUST_HOME=$(grep '^COUNTRIES_TRUST_HOME=' "$userConf" | cut -f 2 -d = | sed "s/'//g")
    logger "Using custom value for user $USER for trusting home country: $COUNTRIES_TRUST_HOME"
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
# and the source used (imap/sogo/roundcube)
# Exit if a script already check this IP address
ipSig=$(echo "$IP:$SOURCE" | md5sum | cut -f 1 -d ' ')
lockFile="$secdir/$ipSig.lock"
test -f "$lockFile" && exit $TRUST

# Start processing, but remove lockfile on exit
touch "$lockFile"
trap 'rm -f $lockFile' EXIT

# If this is a private IP address, pass the hand to
# the next scripts
isPrivate=$(ipcalc "$IP" | grep -c "Private Internet")

if [ "$isPrivate" = "1" ]; then
    exit $TRUST
fi

isIPv6=$(echo "$IP" | grep -c ":")
if [ "$isIPv6" = "1" ]; then
    lookup=$(geoiplookup6 "$IP")
else
    lookup=$(geoiplookup "$IP")
fi

# Check if the country is found or not
# Use XX when not found
notFound=$(echo "$lookup" | grep -c 'IP Address not found')

if [ "$notFound" = "1" ]; then
    echo "IMAP connection from an unknown country (IP=$IP)"
    exit $UNKNOWN_COUNTRY
fi

countryCode=$(echo "$lookup" | sed -r 's/.*: ([A-Z]{2}),.*/\1/g')
countryName=$(echo "$lookup" | cut -f 2 -d , | sed 's/^ //')

# If we trust the same country, just accept the connection
if [ "$HOME_COUNTRY" = "$countryCode" -a "$COUNTRIES_TRUST_HOME" = "YES" ]; then
    exit $TRUST
fi

# Check if the country is trusted
trustedCountry=$(echo "$COUNTRIES_TRUST" | grep -c -E "(^|,)$countryCode(,|$)")
if [ "$trustedCountry" = "1" ]; then
    # If we trust the country we are in, just accept the connection
    exit $TRUST
fi

echo "IMAP connection from a different country ($countryName)"

# Return the malus
exit $NEW_COUNTRY
