#!/bin/sh
#
## Generate or refresh DANE records
## Usage:
##   dane-set-record <subdomain> <port>
## Examples
##   - dane-set-record smtp 25
##   - dane-set-record www 443
##
## This will generate a DNS record automatically,
## with the certificate public key signature.
## SHA256 is used by default
#

# exit codes
SUCCESS=0
PARAM_ERROR=10
CRT_FILE_ERROR=20
DNS_ERROR=30

usage() {
    sed -n 's/^## //p' "$0"
}

# subdomain and dns record to use
sub_domain="$1"
port="$2"
proto="tcp"

# Constants
crt_root=/var/lib/lego/certificates    # Certificates root
hash=SHA256                            # SHA1, RMD160, SHA256, SHA384, SHA512.

if [ -z "$sub_domain" ]; then
    usage
    exit $PARAM_ERROR
fi

if [ -z "$port" ]; then
    usage
    exit $PARAM_ERROR
fi

# Domain to use
domain=$(hostname -d)
fqdn="$sub_domain.$domain"

# Check if the file exists
crt_file="$crt_root/$sub_domain.$domain.crt"

if [ ! -r "$crt_file" ]; then
    echo "Certificate not found for $fqdn" 1>&2
    exit $CRT_FILE_ERROR
fi

# Extract the certificate signature
outfile="/etc/lego/dane/$fqdn.rec"
danetool --tlsa-rr --host "$fqdn" --hash="$hash" \
         --port="$port" --proto="$proto" \
         --load-certificate "$crt_file" \
         --outfile "$outfile"

# Get the DNS record details
name=$(cut -d . -f 1,2,3 < "$outfile")
content=$(sed -E 's/.*TLSA \( ([a-f0-9 ]+) \)/\1/' "$outfile")

# Check if the record exists and is already valid
if danetool --quiet --check="$fqdn" --port="$port" >/dev/null 2>&1; then
    echo "Record already set." 1>&2
    exit $SUCCESS
fi

# Delete old record of exists
if ! pdnsutil delete-rrset  "$domain" "$name" TLSA; then
    echo "No old record to delete" 1>&2
fi

# Add the DNS record
if ! pdnsutil add-record "$domain" "$name" TLSA "$content"; then
    echo "Could not add DNS record" 1>&2
    exit $DNS_ERROR
fi

exit $SUCCESS
