#!/bin/dash

# Check if the connection is inside working hours.
# This is a very simple script that do not check
# timezone. If the country is not the right one, it
# will simply exit

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAs: User
# NeedDecryptKey: No
# Score: Malus
# Description: Working hours range

# Malus scores
TRUST=0

# Used to log errors in syslog or mail.log
log_error() {
    echo "$@" 1>&2;
}

# Read global configuration
# shellcheck disable=SC1091
. /etc/homebox/access-check.conf

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
userconfDir="$HOME/.config/homebox"
userlockDir="$HOME/security"

# Check if the GeoIP lookup binary is available.
# The only reason no would be a user customisation.
# Let's assume he knows what he's doing, but generata a log entry
if [ ! -x /usr/bin/geoiplookup ]; then
    logger -p user.warning "Script access-check-time: Cannot find or execute geoiplookup"
    exit $TRUST
fi

# (setq flycheck-shellcheck-follow-sources nil)

# Create the security directory for the user
test -d "$userconfDir" || mkdir "$userconfDir"

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

# Skip this country
if [ "$notFound" = "1" ]; then
    exit $TRUST
fi

countryCode=$(echo "$lookup" | sed -r 's/.*: ([A-Z]{2}),.*/\1/g')

# We only check working hours in home country for now
# The timezone might be detected later, using ipify.org
if [ "$HOME_COUNTRY" != "$countryCode" ]; then
    exit $TRUST
fi

# Detect the timezone
if [ "$WORKING_TIMEZONE" = "auto" ]; then
    WORKING_TIMEZONE=$(date +%Z)
fi

# get the current hour
hour=$(TZ=$WORKING_TIMEZONE date +'%H')
time=$(TZ=$WORKING_TIMEZONE date +'%H:%M')

# If inside working hours, just exit
if [ "$hour" -ge "$WORKING_TIME_START" ] && [ "$hour" -le "$WORKING_TIME_END" ]; then
    logger "Inside working hours ($time)"
    exit $TRUST
fi

# Check for too early connection
if [ "$hour" -lt "$WORKING_TIME_START" ]; then
    malus=$(( 10 * (WORKING_TIME_START - hour) ))
    echo "Unusual early connection for $WORKING_TIMEZONE ($time)"
    exit $malus
fi

# Check for too late connection
if [ "$hour" -gt "$WORKING_TIME_END" ]; then
    malus=$(( 10 * (hour - WORKING_TIME_END) ))
    echo "Unusual late connection for $WORKING_TIMEZONE ($time)"
    exit $malus
fi

# We should normally not reach this point
logger "Error in access-check-time script"
exit $TRUST
