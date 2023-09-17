#!/bin/sh

# This script dynamically update firewall to whitelist IP addresses,
# for authenticating on submission(s) ports.
# It is called by Dovecot after IMAP authentication succeed.

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# The default duration to use for whitelisting
period="1d"

# List of ports to whitelist
ports="143 993 995 465 587 5222"

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

    # Check if the IP address already contained in the set
    # nft element query does not work with intervals.
    if ! nft list set inet filter "$fw_set" | grep -qF "$IP"; then

        for port in $ports; do
            nft add element inet filter "$fw_set" "{ $IP . $port timeout $period }"
        done

    fi

fi

exec "$@"
