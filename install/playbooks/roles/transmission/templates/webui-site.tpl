#

# Default transmission daemon port
upstream transmission  {
    server 127.0.0.1:9091;
}

# Default server configuration
{% if system.ssl == 'letsencrypt' %}
server {

    # transmission FQDN
    listen 80;
    server_name transmission.{{ network.domain }};

    # Use Letsencrypt and force https
    rewrite ^ https://$server_name$request_uri? permanent;

    # log files per virtual host
    access_log /var/log/nginx/transmission-access.log;
    error_log /var/log/nginx/transmission-error.log;

{% if transmission.public == false %}
    # list of IP addresses to authorize
<<<<<<< HEAD
=======
    satisfy any;
>>>>>>> dev-arodier
{% for ip in transmission.allow %}
    allow {{ ip }};
{% endfor %}
    deny all;
{% endif %}
}
{% endif %}

# Default server configuration
server {

    # transmission FQDN
    server_name transmission.{{ network.domain }};

    # Default transmission web content location
    root /usr/share/transmission/web/;

    # Remove useless tokens for better security feelings ;-)
    server_tokens off;

    {% if system.ssl == 'letsencrypt' %}
    # SSL configuration
    listen 443 ssl http2;
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_certificate /etc/letsencrypt/live/transmission.{{ network.domain }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/transmission.{{ network.domain }}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/transmission.{{ network.domain }}/fullchain.pem;
    {% endif %}

    # log files per virtual host
    access_log /var/log/nginx/transmission-access.log;
    error_log /var/log/nginx/transmission-error.log;

    location ~ ^/favicon\.(ico|png)$ {
        root /usr/share/transmission/web/images/;
    }

    location ^~ / {
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For "";
        proxy_pass_header X-Transmission-Session-Id;
        proxy_set_header Connection "";
        proxy_pass_request_headers on;
        add_header Front-End-Https on;
        proxy_buffering off;

<<<<<<< HEAD
=======
        # Use utf8 as the default charset
        charset utf8;

        # Authenticate users against the pam system, except when using the LAN
        satisfy any;
        auth_pam                "Transmission BitTorrent client";
        auth_pam_service_name   "login";

>>>>>>> dev-arodier
        location /upload {
            proxy_pass http://transmission;
        }

        location /web/ {
            alias /usr/share/transmission/web/;
        }

        location /web/style/ {
            alias /usr/share/transmission/web/style/;
        }

        location /web/javascript/ {
            alias /usr/share/transmission/web/javascript/;
        }

        location /web/images/ {
            alias /usr/share/transmission/web/images/;
        }

        location /rpc {
            proxy_pass http://127.0.0.1:9091/transmission/rpc;
        }
<<<<<<< HEAD
=======

        # Serve downloaded files over https
        location /theme/ {
            alias /usr/share/transmission/web/download-themes/;
        }

        location /downloads/ {

            alias {{ transmission.download_dir }}/;
            fancyindex on;
            fancyindex_exact_size off;  # Output human-readable file sizes.

            # Specify the path to the header.html and foother.html files, that are server-wise,
            # ie served from root of the website. Remove the leading '/' otherwise.
            fancyindex_header "/theme/{{ transmission.download_theme }}/header.html";
            fancyindex_footer "/theme/{{ transmission.download_theme }}/footer.html";

            # Maximum file name length in bytes, change as you like.
            # Warning: if you use an old version of ngx-fancyindex, comment the last line if you
            # encounter a bug. See https://github.com/Naereen/Nginx-Fancyindex-Theme/issues/10
            fancyindex_name_length 255;
        }
>>>>>>> dev-arodier
    }

{% if transmission.public == false %}
    # list of IP addresses to authorize
{% for ip in transmission.allow %}
    allow {{ ip }};
{% endfor %}
    deny all;
{% endif %}
}
