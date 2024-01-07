#!/bin/sh

# Create and publish a new DKIM key using the host name and the year as a selector
# Should be called the first January of every year.
# Does not remove old keys.

# Exit code
SUCCESS=0
KEY_GEN_FAILED=10
DNS_GEN_FAILED=20
DNS_UPD_FAILED=30
SYSTEM_ERROR=40

year=$(date +"%Y")

hostname=$(hostname)
domain=$(hostname -d)

# Build the record name for this year
selector="$hostname-$year"
dns_record_name="$selector._domainkey"

echo "Looking for key $dns_record_name in DNS records"

# Get the IP address of the DNS server
dns_ip=$(sed -En 's/^local-address=([^,]+).*/\1/p' /etc/powerdns/pdns.d/homebox.conf)

# Check if the record already exists
cur_dns_record=$(dig -t TXT "$selector._domainkey.$domain" +nocomment +noall +answer "@$dns_ip")

# If the record already exists, just exit
if [ "$cur_dns_record" != "" ]; then
    echo "Record ‘$selector’ for year $year already set:"
    echo "    $cur_dns_record"
    echo "Exiting"
    exit $SUCCESS
fi

if ! cd /etc/opendkim/keys; then
    echo "Could not enter directory /etc/opendkim/keys"
    exit $SYSTEM_ERROR
fi

# Only create the key if it does not already exists
if test -f "$selector.txt"; then

    echo "Using existing selector '$selector.txt' found"

else

    # Build the arguments
    set -- "--restrict"
    set -- "$@" "--domain=$domain"
    set -- "$@" "--bits=1024"
    set -- "$@" "--selector=$selector"
    set -- "$@" "--note='DKIM key for $hostname on $domain'"

    if ! opendkim-genkey "$@"; then
        echo "Key creation for year $year failed, exiting"
        exit  $KEY_GEN_FAILED
    fi

    echo "Successfully created key for year $year"

fi

# The key should be now in /etc/opendkim/keys/<selector>.txt
# Now, create the new DNS record

if ! cd /etc/opendkim/dns; then
    echo "Could not enter directory /etc/opendkim/dns"
    exit $SYSTEM_ERROR
fi


if test -f "nsupdate-$selector.conf"; then

    echo "Using update file 'nsupdate-$selector.conf' found"

else

    # Build arguments list
    set -- "-d" "$domain" "-F" "-M" "-u" "-T" "86400" "-o" "nsupdate-$selector.conf"

    if ! opendkim-genzone "$@"; then
        echo "DNS record generation failed, exiting"
        exit  $DNS_GEN_FAILED
    fi

    # Use the local IP specific address to avoid an error,
    # as the script connects to localhost by default.
    sed -i "s/^server $hostname$/server 127.1.1.53/" "nsupdate-$selector.conf"

    # Ensure the permissions are correct
    chown opendkim:opendkim "/etc/opendkim/keys/$selector.txt"
    chmod 0640 "/etc/opendkim/keys/$selector.txt"

    chown opendkim:opendkim "/etc/opendkim/keys/$selector.private"
    chmod 0600 "/etc/opendkim/keys/$selector.private"

    echo "Successfully created DNS record"

fi

# Now, create the new DNS record
if ! nsupdate "nsupdate-$selector.conf"; then

    echo "DNS update failed, exiting"
    exit  $DNS_UPD_FAILED

fi

echo "DNS update success."
exit  $SUCCESS
