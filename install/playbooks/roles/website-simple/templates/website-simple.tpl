
# Default server configuration for https://www.{{ network.domain }}
server {

    # Listen on both IPv4 and IPv6
    listen 443 ssl;
    listen [::]:443 ssl;

    # HSTS for better security
    add_header Strict-Transport-Security "max-age=31536000;" always;

    # Web site FQDN
    server_name www.{{ network.domain }};

    # The default web site
    root /var/www/default/;

    # Remove useless tokens for better security feelings ;-)
    server_tokens off;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/www.{{ network.domain }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/www.{{ network.domain }}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/www.{{ network.domain }}/fullchain.pem;

    # Will dynamically fall back to the demo
    # page if there is no index
    index index.html index-demo.html;

    # Do not use a favicon
    location ~ ^/favicon.ico$ {
        root /var/www/default/;
        log_not_found off;
        access_log off;
        expires max;
    }

    # Nothing here
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # log files per virtual host
    access_log /var/log/nginx/website-access.log;
    error_log /var/log/nginx/website-error.log;
}
