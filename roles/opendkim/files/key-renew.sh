#!/bin/sh

# Create and publish a new DKIM key using the host name and the year as a selector
# Should be called the first January of every year.
# Does not remove old keys.

# Exit code
SUCCESS=0
KEY_GEN_FAILED=10
DNS_GEN_FAILED=20
DNS_UPD_FAILED=30

year=$(date +"%Y")

hostname=$(hostname)
domain=$(hostname -d)

# Build the record name for this year
selector="$hostname-$year"
dns_record_name="$selector._domainkey"

echo "Looking for key $dns_record_name in DNS records"

# Check if the record already exists
cur_dns_record=$(dig -t TXT "$selector._domainkey.$domain" +nocomment +noall +answer @127.0.0.1)

# If the record already exists, just exit
if [ "$cur_dns_record" != "" ]; then
    echo "Record ‘$selector’ for year $year already set:"
    echo "    $cur_dns_record"
    echo "Exiting"
    exit $SUCCESS
fi

cd /etc/opendkim/keys

# Only create the key if it does not already exists
if test -f "$selector.txt"; then

    echo "Using existing selector '$selector.txt' found"

else

    # Build the arguments
    gen_args="--restrict"
    gen_args="$gen_args --domain '$domain'"
    gen_args="$gen_args --bits 1024"
    gen_args="$gen_args --selector=$selector"
    gen_args="$gen_args --note='main DKIM key for the domain $domain'"

    if ! opendkim-genkey $gen_args; then
	echo "Key creation for year $year failed, exiting"
	exit  $KEY_GEN_FAILED
    fi

    echo "Successfully created key for year $year"

fi

# The key should be now in /etc/opendkim/keys/<selector>.txt
# Now, create the new DNS record

cd /etc/opendkim/dns

if test -f "nsupdate-$selector.conf"; then

    echo "Using update file 'nsupdate-$selector.conf' found"

else

    # Build arguments list
    ns_args="-d $domain -F -M -u -T 86400 -o nsupdate-$selector.conf"

    if ! opendkim-genzone $ns_args; then
	echo "DNS record generation failed, exiting"
	exit  $DNS_GEN_FAILED
    fi

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
