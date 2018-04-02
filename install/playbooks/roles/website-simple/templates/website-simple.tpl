
# Default server configuration
#
{% if system.ssl == 'letsencrypt' %}
server {

    # Webmail FQDN
    listen 80;
    server_name www.{{ network.domain }} {{ network.domain }};

    # Use Letsencrypt and force https
    {% if system.ssl == 'letsencrypt' %}
    rewrite ^ https://www.{{ network.domain }}$request_uri? permanent;
    {% endif %}
}
{% endif %}

# Default server configuration
#
server {

    # Web site FQDN
    server_name www.{{ network.domain }};

    # The default web site
    root /var/www/default/;

    # Remove useless tokens for better security feelings ;-)
    server_tokens off;

    {% if system.ssl == 'letsencrypt' %}

    # SSL configuration
    listen 443 ssl http2;
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_certificate /etc/letsencrypt/live/www.{{ network.domain }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/www.{{ network.domain }}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/www.{{ network.domain }}/fullchain.pem;
    {% endif %}

    {% if index_page.stat.exists %}

    # Servce the page that exists
    index index.html;

    # Do not use a favicon
    location ~ ^/favicon.ico$ {
        root /var/www/default/;
        log_not_found off;
        access_log off;
        expires max;
    }

    {% else %}

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

    {% endif %}

    # Nothing here
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
}
