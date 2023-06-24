#!/bin/sh

# This script dynamically update firewall to whitelist IP addresses,
# for authenticating on submission(s) ports.
# It is called by Dovecot after IMAP authentication succeed.

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# The default duration to use for whitelisting
period="1d"

# The firewall list to update
fw_set=""

if ipcalc-ng -s -c -4 "$IP"; then
    fw_set="trusted_ipv4"
elif ipcalc-ng -s -c -6 "$IP"; then
    fw_set="trusted_ipv6"
fi

# Submission(s) authentication is now allowed from these IPs.
# imap(S) and pop3s are whitelisted, bypassing subsequent firewall rules.
if [ "$fw_set" != "" ]; then
    nft add element inet filter "$fw_set" "{ $IP . 143 timeout $period }"  # imap
    nft add element inet filter "$fw_set" "{ $IP . 993 timeout $period }"  # imaps
    nft add element inet filter "$fw_set" "{ $IP . 995 timeout $period }"  # pop3s
    nft add element inet filter "$fw_set" "{ $IP . 465 timeout $period }"  # submissions
    nft add element inet filter "$fw_set" "{ $IP . 587 timeout $period }"  # submission
fi

exec "$@"
