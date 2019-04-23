#!/bin/dash

# Check if the connection is from a whitelisted IP address or network.

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAsUser: Yes
# NeedDecryptKey: No
# Score: Bonus
# Description: IP whitelist management

# Whitelisted IP address score: -128
TRUST=128

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

# List of well known and trusted IP addresses
whitelistFile="$secdir/ip-whitelist.txt"

# No whitelist defined for this user
if [ ! -r "$whitelistFile" ]; then
    logger "No wtl file"
    exit $NEUTRAL
fi

# Needed the cidr grep executable
if [ ! -x /usr/bin/grepcidr ]; then
    logger "The program grepcidr is not found or not executable"
    exit $NEUTRAL
fi

# Check if the IP address is whitelisted
whitelisted="0"
if [ -r "$whitelistFile" ]; then
    whitelisted=$(grepcidr -x -c "$IP" "$whitelistFile")
fi

# Exit directly if the IP address has been whitlisted
if [ "$whitelisted" != "0" ]; then
    echo "IP address is whitelisted in $whitelistFile"
    exit $TRUST
fi

# Continue the normal access by default
exit $NEUTRAL
