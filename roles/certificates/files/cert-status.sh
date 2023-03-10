#!/bin/sh

# Start from the certificates directory
cd /etc/lego/certificates

# List all certificate files by time
cert_files=$(ls -1tr *.crt | grep -v issuer)

for cert_file in $cert_files; do

    issuer=$(openssl x509 -in $cert_file -noout -issuer | sed 's/.*= //')
    fqdn=$(openssl x509 -in $cert_file -noout -subject | sed -E 's/.* = ([\*a-z]+).*/\1/')
    from=$(openssl x509 -in $cert_file -noout -dates | sed -En 's/notBefore=(.*)/\1/p')
    till=$(openssl x509 -in $cert_file -noout -dates | sed -En 's/notAfter=(.*)/\1/p')
    sans=$(openssl x509 -in $cert_file -noout -ext subjectAltName | tail -n +2 | sed 's/ //g' | tr '\n' ',')

    line=$(printf "%-16s: %-30s %-30s %-30s %s" "$fqdn" "$from" "$till" "$issuer" "$sans")

    if openssl verify $cert_file >/dev/null 2>&1; then
        echo "$line"
    else
        echo "$line" | colorize Red
    fi

done
