#!/bin/dash

# Check the if the IP address has been already banned by fail2ban

# Post login script for Dovecot, this is parsed by the parrent script.
# Blocking: Yes
# RunAsUser: Yes
# NeedDecryptKey: No
# Score: Malus
# Description: fail2ban history check

# Add this score every time the IP is blacklisted
FAIL2BAN_MALUS=$(grep IPS_FAIL2BAN_MALUS /etc/homebox/access-check.conf | cut -f 2 -d =)

# Use 10 when not empty / not found
if [ "$FAIL2BAN_MALUS" = "" ]; then
    FAIL2BAN_MALUS=10
fi

# Do not change anything when the IP address is not found
NEUTRAL=0

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="$HOME/security"

# Create a unique lock file name for this IP address
# Exit if a script already check this IP address
ipSig=$(echo "$IP:$SOURCE" | md5sum | cut -f 1 -d ' ')
lockFile="$secdir/$ipSig.lock"
test -f "$lockFile" && exit "$TRUST"

# Start processing, but remove lockfile on exit
touch "$lockFile"
trap 'rm -f $lockFile' EXIT

if [ "$TIMES_BANNED" -gt 0 ]; then
    malus=$(( TIMES_BANNED * FAIL2BAN_MALUS ))
    echo "This IP address has been banned $TIMES_BANNED times"
    exit $malus
fi

# Continue the normal access by default
exit $NEUTRAL
