#!/bin/sh
#
## Simple script to renew certificates
## This is normally called by a systemd timer
## Export the environment variable DRYRUN=1 to test
#

# Load parameters
verbose=0
live=0

# Check if we want to run the script in dry-run mode
dryrun="${DRYRUN:=0}"

# The script is using the internal proxy to access ACME site
export http_proxy='http://localhost:8888/'
export https_proxy='http://localhost:8888/'

# Use the SMTP hostname to check if the system is actually "live" on internet
domain=$(hostname -d)
fqdn="smtp.$domain"

if [ "$dryrun" = "1" ]; then

    echo "Running in dry-run mode, the script will just echo commands to run."
    live=0

elif [ "$private_dns" != "$public_dns4" ] && [ "$private_dns" != "$public_dns6" ]; then

    # Check if the DNS server is live
    # Get external IP address signature from local dns server
    private_dns=$(dig "$fqdn" @127.0.1.53 +noall +answer | md5sum | cut -f 1 -d ' ')

    # Get external IP address signature from public dns servers
    public_dns4=$(dig "$fqdn" @1.1.1.1 +noall +answer | md5sum | cut -f 1 -d ' ')
    public_dns6=$(dig "$fqdn" @2606:4700:4700::64 +noall +answer | md5sum | cut -f 1 -d ' ')

    echo "DNS server is not live yet, the script will just echo commands to run."
    live=0

else

    echo "DNS server is live, the script will run the certificate update."
    live=1

fi

# List all the certificates
certs=$(find /var/lib/lego/certificates/ -name '*.key')

# Load DNS and common settings
export PDNS_API_URL=$(sed -n s/^PDNS_API_URL=//p /etc/lego/renew.conf)
export PDNS_API_KEY=$(sed -n s/^PDNS_API_KEY=//p /etc/lego/renew.conf)

cert_server=$(sed -n s/^CERT_SERVER=//p /etc/lego/renew.conf)
cert_email=$(sed -n s/^CERT_EMAIL=//p /etc/lego/renew.conf)

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

    if [ "$live" = "1" ]; then
        lego $common_options renew $renew_options
    else
        echo "lego $common_options renew $renew_options"
    fi

done
