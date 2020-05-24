#!/bin/dash

for fqdn in $RENEWED_DOMAINS; do

    # Get the subdomain
    sub=$(expr "$fqdn" : '\([^.]*\)')

    if [ "$sub" = "smtp" ]; then
        echo "Reloading postfix server"
        systemctl restart postfix
        break
    fi
done
