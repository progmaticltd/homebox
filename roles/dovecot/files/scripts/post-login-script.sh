#!/bin/sh

# This script dynamically update firewall to whitelist IP addresses,
# for authenticating on submission(s) ports.
# It is called by Dovecot after IMAP authentication succeed.

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# The default duration to use for whitelisting
period="1d"

# List of possible ports to whitelist
ports="110 995 143 993 465 587 4190"

for port in $ports; do

    # Skip the ports that are not listening
    if ! nc -z 127.0.0.1 $port; then
       continue
    fi

    fw-control trust "$IP" "$port" "$period"

done

exec "$@"
