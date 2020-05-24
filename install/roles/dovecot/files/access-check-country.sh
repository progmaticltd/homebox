#!/bin/dash

# Check if the connection is from a whitelisted country.

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAs: User
# NeedDecryptKey: No
# Score: Malus
# Description: Country policy checker

# Malus scores
TRUST=0

# This pass shellcheck and enforce a numeric value
COUNTRIES_FOREIGN_MALUS=$((COUNTRIES_FOREIGN_MALUS == 0 ? 255 : COUNTRIES_FOREIGN_MALUS))

# Used to log errors in syslog or mail.log
log_error() {
    echo "$@" 1>&2;
}

# Read the gloabal check access policy
globalConf='/etc/homebox/access-check.conf'

# Read global configuration
# shellcheck disable=SC1090
. "$globalConf"

# Make sure unknown country and blacklist have a default value
# if this is not specified in the configuration.
# This also pass shellcheck test
COUNTRIES_UNKNOWN_MALUS=$((COUNTRIES_UNKNOWN_MALUS == 0 ? 40 : COUNTRIES_UNKNOWN_MALUS))
BLACKLIST_MALUS=$((BLACKLIST_MALUS == 0 ? 255 : BLACKLIST_MALUS))

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
userConfDir="$HOME/.config/homebox"
userlockDir="$HOME/security"

# Read the user policy if it has been customised
userConf="$userConfDir/access-check.conf"

CUSTOM_COUNTRIES_TRUST=$(grep -c '^COUNTRIES_TRUST=' "$userConf")
CUSTOM_COUNTRIES_TRUST_HOME=$(grep -c '^COUNTRIES_TRUST_HOME=' "$userConf")

# Allow the use to defined extra trusted countries
if [ "$CUSTOM_COUNTRIES_TRUST" = "1" ]; then
    COUNTRIES_TRUST=$(grep '^COUNTRIES_TRUST=' "$userConf" | cut -f 2 -d = | sed "s/'//g")
    logger "Using custom value for user $USER for trusted countries: $COUNTRIES_TRUST"
fi

if [ "$CUSTOM_COUNTRIES_TRUST_HOME" = "1" ]; then

    COUNTRIES_TRUST_HOME=$(grep '^COUNTRIES_TRUST_HOME=' "$userConf" | cut -f 2 -d = | sed "s/'//g")
    logger "Using custom value for user $USER for trusting home country: $COUNTRIES_TRUST_HOME"
fi

if [ "$COUNTRIES_TRUST_HOME" = "YES" ]; then
    # Get the current home country
    HOME_COUNTRY=$(grep 'COUNTRY_CODE' /etc/homebox/external-ip | cut -f 2 -d =)
else
    HOME_COUNTRY='--'
fi

# Check if the GeoIP lookup binary is available.
# The only reason no would be a user customisation.
# Let's assume he knows what he's doing, but generata a log entry
if [ ! -x /usr/bin/geoiplookup ]; then
    logger -p user.warning "Script access-check-country: Cannot find or execute geoiplookup"
    exit $TRUST
fi

# Create the security directory for the user
test -d "$userConfDir" || mkdir "$userConfDir"

# Create a unique lock file name for this IP address
# and the source used (imap/sogo/roundcube)
# Exit if a script already check this IP address
ipSig=$(echo "$IP:$SOURCE" | md5sum | cut -f 1 -d ' ')
lockFile="$userlockDir/$ipSig.lock"
test -f "$lockFile" && exit $TRUST

# Start processing, but remove lockfile on exit
touch "$lockFile"
trap 'rm -f $lockFile' EXIT

isIPv6=$(echo "$IP" | grep -c ":")
if [ "$isIPv6" = "1" ]; then
    lookup=$(geoiplookup6 "$IP")
else
    lookup=$(geoiplookup "$IP")
fi

# Check if the country is found or not
notFound=$(echo "$lookup" | grep -c 'IP Address not found')

if [ "$notFound" = "1" ]; then
    echo "IMAP connection from an unknown country"
    exit $COUNTRIES_UNKNOWN_MALUS
fi

countryCode=$(echo "$lookup" | sed -r 's/.*: ([A-Z]{2}),.*/\1/g')
countryName=$(echo "$lookup" | cut -f 2 -d , | sed 's/^ //')

# Check if the country is blacklisted
blacklistedCountry=$(echo "$COUNTRIES_BLACKLIST" | grep -c -E "(^|,)$countryCode(,|$)")
if [ "$blacklistedCountry" = "1" ]; then
    echo "The country '$countryName' is blacklisted"
    exit $BLACKLIST_MALUS
fi

# If we trust the same country, just accept the connection
if [ "$HOME_COUNTRY" = "$countryCode" ] && [ "$COUNTRIES_TRUST_HOME" = "YES" ]; then
    exit $TRUST
fi

# Check if the country is trusted
trustedCountry=$(echo "$COUNTRIES_TRUST" | grep -c -E "(^|,)$countryCode(,|$)")
if [ "$trustedCountry" = "1" ]; then
    # If we trust the country we are in, just accept the connection
    exit $TRUST
fi

# Return the malus for a foreign country
echo "IMAP connection from a different country ($countryName)"
exit $COUNTRIES_FOREIGN_MALUS
