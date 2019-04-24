#!/bin/dash

# Check if the connection is from a blacklisted IP address or network.

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAsUser: Yes
# NeedDecryptKey: No
# Score: Malus
# Description: IP blacklist management

# Blacklisted IP address score:
BLACKLIST_SCORE=$(grep BLACKLIST_MALUS /etc/homebox/access-check.conf | cut -f 2 -d =)

# Do not change anything when the IP address is not found
NEUTRAL=0

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="$HOME/security"

# Create a unique lock file name for this IP address
# Exit if a script already check this IP address
ipSig=$(echo "$IP" | md5sum | cut -f 1 -d ' ')
lockFile="$secdir/$ipSig.lock"
test -f "$lockFile" && exit $BLACKLIST_SCORE

# Start processing, but remove lockfile on exit
touch "$lockFile"
trap 'rm -f $lockFile' EXIT

# List of well known and trusted IP addresses
blacklistFile="$secdir/ip-blacklist.txt"

# No blacklist defined for this user
if [ ! -r "$blacklistFile" ]; then
    logger "No wtl file"
    exit $NEUTRAL
fi

# Needed the cidr grep executable
if [ ! -x /usr/bin/grepcidr ]; then
    logger "The program grepcidr is not found or not executable"
    exit $NEUTRAL
fi

# Check if the IP address is blacklisted
blacklisted="0"
if [ -r "$blacklistFile" ]; then
    blacklisted=$(grepcidr -x -c "$IP" "$blacklistFile")
fi

# Exit directly if the IP address has been blacklisted
if [ "$blacklisted" != "0" ]; then
    echo "IP address is blacklisted by $USER"
    exit $BLACKLIST_SCORE
fi

# Continue the normal access by default
exit $NEUTRAL
