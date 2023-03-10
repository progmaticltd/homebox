#!/bin/sh

# List all certificate files
cd /etc/lego/certificates
cert_files=$(ls -1 *.crt | grep -v issuer)

for cert_file in $cert_files; do

    fqdn=$(openssl x509 -in $cert_file -noout -subject | sed -E 's/.* = ([^\.]+)/\1/')
    from=$(openssl x509 -in $cert_file -noout -dates | sed -En 's/notBefore=(.*)/\1/p')
    till=$(openssl x509 -in $cert_file -noout -dates | sed -En 's/notAfter=(.*)/\1/p')
    sans=$(openssl x509 -in $cert_file -noout -text | grep -A 1 'Subject Alternative Name' | grep -v 'X509' | sed -E 's/^ +//' | tr '\n' ',')

    printf "%-30s: %-30s %-30s %s\n" "$fqdn" "$from" "$till" "$sans"

done
