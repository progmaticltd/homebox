#!/bin/dash
#
##
## Simple script to manage or get the status of the certificate
## The first parameter is the action to do:
## - status: Check if the last certificate is live and valid, return Live / Not live
## - activate: Activate the last certificate if it is not live, i.e. reload nginx
##
## This script is automatically called by certificate renewal (action=activate)
## or by the cert-status parent script (action=status)
##
#

# Load the action to run
action="$1"

usage() {
    sed -n "s/^##//p" "$0"
}

if [ -z "$action" ] || [ "$action" = "-h" ] || [ "$action" = "--help" ]; then
    usage
    exit
elif [ "$action" != "status" ] && [ "$action" != "activate" ]; then
    usage
    exit 1
fi

# Get the domain
domain=$(hostname -d)
fqdn="imap.$domain"
cert_path="/var/lib/lego/certificates/$fqdn.crt"

# Load server certificate dates
server_dates=$(echo "" | openssl s_client -showcerts -servername $fqdn -connect $fqdn:993 2>&1 | openssl x509 -noout -dates)
server_until=$(echo "$server_dates" | sed -En 's/notAfter=(.*)/\1/p')

# Load file certificate dates
file_dates=$(openssl x509 -in "$cert_path" -noout -dates)
file_until=$(echo "$file_dates" | sed -En 's/notAfter=(.*)/\1/p')

# Compute
server_until_epoch=$(date +%s -d "$server_until")
file_until_epoch=$(date +%s -d "$file_until")

# When activating the new certificate, set the dane record and restart dovecot
if [ $server_until_epoch -lt $file_until_epoch ]; then
    if [ "$action" = "status" ]; then
        echo "Not live"
    elif [ "$action" = "activate" ]; then
        /usr/local/sbin/dane-set-record imap 993
        /usr/local/sbin/dane-set-record imap 143
        systemctl restart dovecot
    fi
elif [ "$action" = "status" ]; then
    echo "Live"
fi
