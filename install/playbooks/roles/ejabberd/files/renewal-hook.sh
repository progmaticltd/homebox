#!/bin/dash

# Exit if jabber server is not running
systemctl status ejabberd >/dev/null 2>&1 || exit 0

# shellcheck disable=SC1091
. /etc/homebox/main.cf

for fqdn in $RENEWED_DOMAINS; do

    # Get the subdomain
    sub=$(expr "$fqdn" : '\([^.]*\)')

    if [ "$sub" = "xmpp" ] || [ "$sub" = "conference" ]; then
        echo "Reloading XMPP ejabberd server"
        cd "/etc/letsencrypt/live/$DOMAIN"

        /bin/cat privkey.pem fullchain.pem > /etc/ejabberd/default.pem
        chown ejabberd:root /etc/ejabberd/default.pem
        chmod 640 /etc/ejabberd/default.pem
        systemctl restart ejabberd
        break
    fi
done
