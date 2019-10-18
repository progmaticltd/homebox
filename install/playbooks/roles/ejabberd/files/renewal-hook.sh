#!/bin/dash

# Exit if jabber server is not running
systemctl status ejabberd >/dev/null 2>&1 || exit 0

. /etc/homebox/main.cf

do_restart=0

for fqdn in $RENEWED_DOMAINS; do

    # Get the subdomain
    sub=$(expr "$fqdn" : '\([^.]*\)')

    if [ "$sub" = "xmpp" ]; then
        cd "/etc/letsencrypt/live/$DOMAIN"
        /bin/cat privkey.pem fullchain.pem > /etc/ejabberd/default.pem
        do_restart=1
    fi

    if [ "$sub" = "conference" ]; then
        cd "/etc/letsencrypt/live/$DOMAIN"
        /bin/cat privkey.pem fullchain.pem > /etc/ejabberd/conference.pem
        do_restart=1
    fi
done

if [ "$do_restart" = "1" ]; then
    echo "Reloading XMPP ejabberd server"
    chown ejabberd:root /etc/ejabberd/*.pem
    chmod 640 /etc/ejabberd/*.pem
    systemctl restart ejabberd
fi
