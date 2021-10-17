#!/bin/dash
# This hook script loads all the renewed domains, and restart ejabberd only once

# Exit if jabber server is not running
systemctl status ejabberd >/dev/null 2>&1 || exit 0

# Load homebox settings
. /etc/homebox/main.cf

# Do not restart by default
do_restart=0

for fqdn in $RENEWED_DOMAINS; do

    # Get the subdomain
    sub=$(expr "$fqdn" : '\([^.]*\)')

    if [ "$fqdn" = "$DOMAIN" ]; then
        do_restart=1
    else

        case subdomain in
            conference)
                do_restart=1
                break
                ;;
            vjud)
                do_restart=1
                break
                ;;
            proxy)
                do_restart=1
                break
                ;;
            pubsub)
                do_restart=1
                break
                ;;
            conference)
                do_restart=1
                break
                ;;
        esac
    fi

done

if [ "$do_restart" = "1" ]; then
    systemctl restart ejabberd
fi
