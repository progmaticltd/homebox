#!/bin/sh

# Start from the certificates directory
cd /etc/lego/certificates || exit

# List all certificate files by time
cert_files=$(find /var/lib/lego/certificates/ -maxdepth 1 -name '*.crt' | grep -Fv .issuer.crt)

# System CA to use to check the certificates
ca_system="/etc/ssl/certs/ca-certificates.crt"

# The parent domain
domain=$(hostname -d)

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

    ca_file=$(echo "$cert_file" | sed 's/\.crt$/.issuer.crt/')
    key_file=$(echo "$cert_file" | sed 's/\.crt$/.key/')
    issuer=$(openssl x509 -in "$cert_file" -noout -issuer | sed 's/.*= //')
    from=$(openssl x509 -in "$cert_file" -noout -dates | sed -En 's/notBefore=(.*)/\1/p')
    till=$(openssl x509 -in "$cert_file" -noout -dates | sed -En 's/notAfter=(.*)/\1/p')
    sans=$(openssl x509 -in "$cert_file" -noout -ext subjectAltName | tail -n +2 | sed 's/ //g' | tr '\n' ',' | sed 's/,$//')

    # Used for path
    subdomain=$(openssl x509 -in "$cert_file" -noout -subject | sed 's/subject=CN = //g' | sed -E "s/\\.?$domain//g")

    # Get the key type
    key_type=$(sed -En 's/.*BEGIN (EC|RSA) PRIVATE KEY.*/\1/p' "$key_file")

    # Check modulus
    key_modulus=""
    crt_modulus=""

    if [ "$key_type" = "EC" ]; then
        key_modulus=$(openssl ec -in "$key_file" -check 2>&1 | grep 'EC Key valid')
        crt_modulus="EC Key valid."
    elif [ "$key_type" = "RSA" ]; then
        key_modulus=$(openssl rsa -noout -modulus -in "$key_file" | openssl sha256)
        crt_modulus=$(openssl x509 -noout -modulus -in "$cert_file" | openssl sha256)
    fi

    # Compute dates
    today=$(date +%s)
    till_days=$(date +%s -d "$till")
    valid_days=$(((till_days - today) / 86400))

    from_short=$(date +"%x" -d "$from")
    till_short=$(date +"%x" -d "$till")

    # Get the cert status if implemented
    status="Unknown"
    status_script_path="/etc/lego/hooks/$subdomain.$domain/renew-cert.sh"
    if [ "$subdomain" = "*" ]; then
	status_script_path="/etc/lego/hooks/_.$domain/renew-cert.sh"
    elif [ "$subdomain" = "" ]; then
	status_script_path="/etc/lego/hooks/$domain/renew-cert.sh"
    fi
    if [ -x "$status_script_path" ]; then
	status=$("$status_script_path" status 2>&1)
    fi

    if [ "$key_modulus" != "$crt_modulus" ]; then
        printf "%s|%s|%s|%s|%s|%s|%s|%s|Mismatch!\n" \
               "$subdomain" "$from_short" "$till_short" "$valid_days" "$issuer" "$sans" "$key_type" "$status">>"$temp_file"
    elif openssl verify -trusted "$ca_system" -trusted "$ca_file" "$cert_file" >/dev/null 2>&1; then
        printf "%s|%s|%s|%s|%s|%s|%s|%s|OK\n" \
               "$subdomain" "$from_short" "$till_short" "$valid_days" "$issuer" "$sans" "$key_type" "$status">>"$temp_file"
    else
        error=$(openssl verify -trusted "$ca_system" -trusted "$ca_file" "$cert_file" 2>&1 | sed -En 's/.*: //p')
        error=$(echo "$error" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
        printf "%s|%s|%s|%s|%s|%s|%s|%s|$error\n" \
               "$subdomain" "$from_short" "$till_short" "$valid_days" "$issuer" "$sans" "$key_type" "$status">>"$temp_file"
    fi

done

# Display the output table formatted
columns='Domain,Valid from,Valid until,Days left,Issuer,Full domains list,Type,Status,Details'
column -t -s '|' -o '  | ' -N "$columns" -W Status "$temp_file"

# Remove temporary files
cleanup
