#!/bin/dash

# Check the IP address against rblcheck

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAsUser: Yes
# NeedDecryptKey: No
# Score: Malus
# Description: IP rblcheck

# returns 10 * each time the IP is blacklisted
BLACKLISTED=10

# Do not change anything when the IP address is not found
NEUTRAL=0

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="$HOME/security"

# Create a unique lock file name for this IP address
# Exit if a script already check this IP address
ipSig=$(echo "$IP" | md5sum | cut -f 1 -d ' ')
lockFile="$secdir/$ipSig.lock"
test -f "$lockFile" && exit $TRUST

# Start processing, but remove lockfile on exit
touch "$lockFile"
trap 'rm -f $lockFile' EXIT

# Needed the rblcheck executable
if [ ! -x /usr/bin/rblcheck ]; then
    logger "The program rblcheck is not found or not executable"
    exit $NEUTRAL
fi

# Count the number of times the IP is blacklisted
rblStatus=$(rblcheck "$IP")
listedCount=$?

if [ "$listedCount" != "0" ]; then
    echo "This IP address is blacklisted $listedCount times."
    cost=$(( 50 * listedCount ))
    exit $cost
fi

# Continue the normal access by default
exit $NEUTRAL
