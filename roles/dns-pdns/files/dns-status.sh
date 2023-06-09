#!/bin/sh

## Show DNS status: dnssec, published, errors, etc.
##
## syntax: dns-status

# Return code
SUCCESS=0
DOMAIN_NOT_LIVE=10
DNSSEC_NOT_LIVE=20

# Init
domain=$(hostname -d)

# Diagnostic functions
dnskeys_details() {

    loc_keys=$(mktemp)
    pub_keys=$(mktemp)

    dig DNSKEY "$domain" "@127.1.1.53" +short | sort >$loc_keys
    dig DNSKEY "$domain" "@${dns_server}" +short | sort >$pub_keys

    diff -y --color "$loc_keys" "$pub_keys"

    rm -f "$loc_keys" "$pub_keys"
}

# Check if I can use IPv6
if host "$domain" 2606:4700:4700::64 2>&1 >/dev/null; then
    dns_server=2606:4700:4700::64
elif host "$domain" 1.1.1.1 2>&1 >/dev/null; then
    dns_server=1.1.1.1
else
    printf "DNS server for ${domain} is not live."
    exit $DOMAIN_NOT_LIVE
fi

# Load DNS keys from an external server
public_keys=$(dig DNSKEY "$domain" "@${dns_server}" +short | sort | md5sum | cut -f 1 -d ' ')
local_keys=$(dig DNSKEY "$domain" "@127.1.1.53" +short | sort | md5sum | cut -f 1 -d ' ')

if [ "$public_keys" != "$local_keys" ]; then

    printf "DNS keys are not published\n"
    dnskeys_details
    exit $DNSSEC_NOT_LIVE

fi

# Keys are live and published
printf "DNS keys are published:\n"

# Display DNSSEC keys
pdnsutil list-keys "$domain"
