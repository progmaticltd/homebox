#!/bin/dash

for fqdn in $RENEWED_DOMAINS; do

    # Get the subdomain
    sub=$(expr "$fqdn" : '\([^.]*\)')

    if [ "$sub" = "ldap" ]; then
        echo "Reloading LDAP server"
        systemctl stop nslcd
        systemctl restart slapd
        systemctl start nslcd
    fi
done
