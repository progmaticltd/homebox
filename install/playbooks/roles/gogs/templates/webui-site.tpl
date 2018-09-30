
# Default server configuration
{% if system.ssl == 'letsencrypt' %}
server {

    # gogs FQDN
    listen 80;
    server_name gogs.{{ network.domain }};

    # Certificate renewal
    location /.well-known {
        alias /var/www/gogs/.well-known;
    }

    location / {

        # Use Letsencrypt and force https
        rewrite ^ https://$server_name$request_uri? permanent;

        # log files per virtual host
        access_log /var/log/nginx/gogs-access.log;
        error_log /var/log/nginx/gogs-error.log;

{% if gogs.public == false %}
        # list of IP addresses to authorize
{% for ip in gogs.allow %}
        allow {{ ip }};
{% endfor %}
        deny all;
{% endif %}
    }
}
{% endif %}

# Default server configuration
server {

    # gogs FQDN
    server_name gogs.{{ network.domain }};

    # Default gogs location from the package
    root /opt/gogs/public/;

    # Remove useless tokens for better security feelings ;-)
    server_tokens off;

    {% if system.ssl == 'letsencrypt' %}
    # SSL configuration
    listen 443 ssl http2;
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_certificate /etc/letsencrypt/live/gogs.{{ network.domain }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gogs.{{ network.domain }}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/gogs.{{ network.domain }}/fullchain.pem;
    {% endif %}

    # log files per virtual host
    access_log /var/log/nginx/gogs-access.log;
    error_log /var/log/nginx/gogs-error.log;

    location ~ ^/favicon.ico$ {
        root /opt/gogs/public/img/;
    }

    # Nothing here
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location / {
        proxy_pass http://localhost:6000;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For "";
    }

    # list of IP addresses to authorize
{% if gogs.public == false %}
{% for ip in gogs.allow %}
    allow {{ ip }};
{% endfor %}
    deny all;
{% endif %}
}
