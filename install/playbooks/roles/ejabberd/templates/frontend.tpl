
# Default server configuration
#
# for http://xmpp.{{ network.domain }}
# redirect everything to https
{% if system.ssl == 'letsencrypt' %}
server {

    # frontend
    listen 80;
    server_name xmpp.{{ network.domain }};

    # Use Letsencrypt and force https
    rewrite ^ https://$server_name$request_uri? permanent;

    # log files per virtual host
    access_log /var/log/nginx/jabber-access.log;
    error_log /var/log/nginx/jabber-error.log;
}
{% endif %}

# HTTPS server configuration
# for https://xmpp.{{ network.domain }}
server {

    # frontend
    server_name xmpp.{{ network.domain }};

    # The default web site
    root /var/www/ejabberd/files/;

    # Remove useless tokens for better security feelings ;-)
    server_tokens off;

    {% if system.ssl == 'letsencrypt' %}
    # SSL configuration
    listen 443 ssl http2;
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_certificate /etc/letsencrypt/live/xmpp.{{ network.domain }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/xmpp.{{ network.domain }}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/xmpp.{{ network.domain }}/fullchain.pem;
    {% endif %}

    # There is an empty page to avoid error if accessing the site with
    # a web browser
    index index.html;

    # Do not use a favicon
    location ~ ^/favicon.ico$ {
        root /var/www/ejabberd/files/;
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

    # Pass file upload to the proxy
    location ~ ^/upload.* {
        proxy_pass http://127.0.0.1:{{ ejabberd.http_upload.port }}/$request_uri?;
	proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # log files per virtual host
    access_log /var/log/nginx/jabber-access.log;
    error_log /var/log/nginx/jabber-error.log;
}
