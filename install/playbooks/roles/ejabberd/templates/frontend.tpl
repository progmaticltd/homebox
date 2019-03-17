
# HTTPS server configuration
# for https://xmpp.{{ network.domain }}
server {

    # Listen on IPv4 and IPv6
    listen 443 ssl http2;
    listen [::]:443;

    # HSTS for better security
    add_header Strict-Transport-Security "max-age=31536000;" always;

    # frontend
    server_name xmpp.{{ network.domain }};

    # The default web site
    root /var/www/ejabberd/files/;

    # Remove useless tokens for better security feelings ;-)
    server_tokens off;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/xmpp.{{ network.domain }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/xmpp.{{ network.domain }}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/xmpp.{{ network.domain }}/fullchain.pem;

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

        # upload limits
        client_max_body_size {{ ejabberd.http_upload.max_size }};
        client_body_in_file_only clean;
        client_body_buffer_size 32K;
        sendfile on;
        send_timeout 300s;
    }

    # log files per virtual host
    access_log /var/log/nginx/jabber-access.log;
    error_log /var/log/nginx/jabber-error.log;
}
