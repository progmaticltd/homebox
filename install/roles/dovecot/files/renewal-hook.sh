#!/bin/dash

# This hook to allows dovecot to read new LDAP certificates

. /etc/homebox/main.cf

do_restart=0

for fqdn in $RENEWED_DOMAINS; do

    # Get the subdomain
    sub=$(expr "$fqdn" : '\([^.]*\)')

    if [ "$sub" = "ldap" ]; then
        cd "$RENEWED_LINEAGE"
        setfacl -m u:dovecot:r -m m:r cert*pem *chain*.pem
        # Restart the dovecot server (might be not needed)
        echo "Reloading Dovecot server"
        systemctl restart dovecot
        break
    fi
done
