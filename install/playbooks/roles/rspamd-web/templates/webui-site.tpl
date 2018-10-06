
# Default server configuration
#
{% if system.ssl == 'letsencrypt' %}
server {

    # Webmail FQDN
    listen 80;
    server_name rspamd.{{ network.domain }};

    # Certificate renewal
    location /.well-known {
        alias /var/www/rspamd/.well-known;
    }

    location / {
        # Use Letsencrypt and force https
        rewrite ^ https://$server_name$request_uri? permanent;

        # log files per virtual host
        access_log /var/log/nginx/rspamd-access.log;
        error_log /var/log/nginx/rspamd-error.log;

        # list of IP addresses to authorize
{% for ip in mail.antispam.webui.allow %}
        allow {{ ip }};
{% endfor %}
        deny all;
    }
}
{% endif %}

# Default server configuration
#
server {

    # Webmail FQDN
    server_name rspamd.{{ network.domain }};

    # Default rspamd location on Debian
    root /usr/share/rspamd/www/;

    # Remove useless tokens for better security feelings ;-)
    server_tokens off;

    {% if system.ssl == 'letsencrypt' %}
    # SSL configuration
    listen 443 ssl http2;
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_certificate /etc/letsencrypt/live/rspamd.{{ network.domain }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rspamd.{{ network.domain }}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/rspamd.{{ network.domain }}/fullchain.pem;
    {% endif %}

    # Add index.php to the list if you are using PHP
    index index.html;

    # log files per virtual host
    access_log /var/log/nginx/rspamd-access.log;
    error_log /var/log/nginx/rspamd-error.log;

    # Do not use a favicon
    location ~ ^/favicon.ico$ {
        root /usr/share/rspamd/www/;
    }

    # Nothing here
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ~ ^/(js|css|fonts|img)/.*$ {
        root /usr/share/rspamd/www/;
    }

    location / {
        proxy_pass http://localhost:{{ 2 + mail.antispam.port }}/;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host      $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For "";
    }

    # list of IP addresses to authorize
{% for ip in mail.antispam.webui.allow %}
    allow {{ ip }};
{% endfor %}
    deny all;
}
