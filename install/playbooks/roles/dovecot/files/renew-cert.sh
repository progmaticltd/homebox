#!/bin/dash

for fqdn in $RENEWED_DOMAINS; do

    # Get the subdomain
    sub=$(expr "$fqdn" : '\([^.]*\)')

    if [ "$sub" = "imap" ] || [ "$sub" = "pop3" ]; then
        echo "Reloading dovecot server"
        systemctl restart dovecot
        break
    fi
done
