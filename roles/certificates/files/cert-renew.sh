#!/bin/sh

# Get fqdn
domain=$(hostname -d)
fqdn="smtp.$domain"

# Get external IP address signature from local dns server
private_dns=$(dig "$fqdn" @127.0.1.53 +noall +answer | md5sum | cut -f 1 -d ' ')

# Get external IP address signature from public dns servers
public_dns4=$(dig "$fqdn" @1.1.1.1 +noall +answer | md5sum | cut -f 1 -d ' ')
public_dns6=$(dig "$fqdn" @2606:4700:4700::64 +noall +answer | md5sum | cut -f 1 -d ' ')

# Check if the DNS server is live
if [ "$private_dns" != "$public_dns4" ] && [ "$private_dns" != "$public_dns6" ]; then
    echo "DNS server is not live yet."
    exit
fi

# List all the certificates
certs=$(find /var/lib/lego/certificates/ -name '*.key')

# Load DNS and common settings
export PDNS_API_URL=$(sed -n s/^PDNS_API_URL=//p /etc/lego/renew.conf)
export PDNS_API_KEY=$(sed -n s/^PDNS_API_KEY=//p /etc/lego/renew.conf)

cert_server=$(sed -n s/^CERT_SERVER=//p /etc/lego/renew.conf)
cert_email=$(sed -n s/^CERT_EMAIL=//p /etc/lego/renew.conf)

export http_proxy='http://localhost:8888/'
export https_proxy='http://localhost:8888/'

for cert in $certs; do

    # Get the FQDN from the filename
    fqdn=$(basename "$cert" '.key')
    echo "Checking $fqdn"

    # Initialise the options
    common_options=""

    common_options="$common_options --server $cert_server"
    common_options="$common_options --email $cert_email"
    common_options="$common_options --dns pdns"
    common_options="$common_options --accept-tos"
    common_options="$common_options --path /etc/lego"
    common_options="$common_options --domains $fqdn"

    # Test if the pem file exists for this certificate
    if test -f /var/lib/lego/certificates/$fqdn.pem; then
        common_options="$common_options --pem"
    fi

    renew_options="--reuse-key"
    renew_options="$renew_options --renew-hook run-parts /etc/lego/hooks/$fqdn/"

    lego $common_options renew $renew_options

done
