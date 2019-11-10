#!/bin/dash

# shellcheck disable=SC1091
. /etc/homebox/main.cf

restart_nginx=0

for fqdn in $RENEWED_DOMAINS; do

    # Get the subdomain
    if [ "$fqdn" = "www.$DOMAIN" ] || [ "$fqdn" = "$DOMAIN" ]; then
        restart_nginx=1
    else
        # Check if there is a web site for this certificate
        # exclude certificate renewal sites files, named -cert.conf
        restart_nginx=$(grep -Rl "server_name $fqdn" /etc/nginx/sites-enabled/ | grep -v -e -cert -c)
    fi

    if [ "$restart_nginx" = "1" ]; then
        echo "Reloading main web site"
        systemctl restart nginx
        break
    fi
done
