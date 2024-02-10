#!/bin/sh
#
## Simple script to call the hooks of the renewed certificates
## It receives the following environment variables:
## - LEGO_ACCOUNT_EMAIL: the email of the account.
## - LEGO_CERT_DOMAIN: the main domain of the certificate.
## - LEGO_CERT_PATH: the path of the certificate.
## - LEGO_CERT_KEY_PATH: the path of the certificate key.
#

hook_dir="/etc/lego/hooks/$LEGO_CERT_DOMAIN/"

# Exit when there is nothing to run
if [ ! -d "$hook_dir" ]; then
    exit
fi

run-parts "$hook_dir"
