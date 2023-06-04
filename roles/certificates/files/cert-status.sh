#!/bin/sh

# Start from the certificates directory
cd /etc/lego/certificates

# List all certificate files by time
cert_files=$(ls -1tr *.crt | grep -v issuer)

# Create the temporary output
temp_file=$(mktemp)

# Remove temporary files on exit
trap cleanup 1 2 3 6
cleanup()
{
    rm -rf "temp_file"
}

# Create the summary table
for cert_file in $cert_files; do

    cafile=$(echo $cert_file | sed 's/^\.crt$/.issuer.crt/')
    issuer=$(openssl x509 -in $cert_file -noout -issuer | sed 's/.*= //')
    fqdn=$(openssl x509 -in $cert_file -noout -subject | sed -E 's/.* = (DNS:)?([\*a-z]+).*/\2/')
    from=$(openssl x509 -in $cert_file -noout -dates | sed -En 's/notBefore=(.*)/\1/p')
    till=$(openssl x509 -in $cert_file -noout -dates | sed -En 's/notAfter=(.*)/\1/p')
    sans=$(openssl x509 -in $cert_file -noout -ext subjectAltName | tail -n +2 | sed 's/ //g' | tr '\n' ',' | sed 's/,$//')

    # Compute dates
    today=$(date +%s)
    till_days=$(date +%s -d "$till")
    valid_days=$(((till_days - today) / 86400))

    if openssl verify -untrusted $cafile $cert_file >/dev/null 2>&1; then
        printf "%s|%s|%s|%s|%s|%s|OK\n" "$fqdn" "$from" "$till" "$valid_days" "$issuer" "$sans" >>$temp_file
    else
        error=$(openssl verify -CAfile $cafile $cert_file 2>&1 | sed -En 's/.*: //p')
        error=$(echo "$error" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
        printf "%s|%s|%s|%s|%s|%s|$error\n" "$fqdn" "$from" "$till" "$valid_days" "$issuer" "$sans" >>$temp_file
    fi

done

# Display the output table formatted
columns='Domain,Valid from,Valid until,Days left,Issuer,Full domains list,Status'
column -t -s '|' -o '  | ' -N "$columns" -W Status $temp_file

# Remove temporary files
cleanup
