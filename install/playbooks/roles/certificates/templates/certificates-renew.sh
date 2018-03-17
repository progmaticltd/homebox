#!/bin/dash

# When the context is 'cron', we sleep between 1 and 59 minutes
context=$1

# Get the list of certificates installed
certificates=$(ls /etc/letsencrypt/live/)

# Create a list of services to restart if necessary
dovecot_reload="no"
postfix_reload="no"
slapd_reload="no"

# Should we run the renew certificate command
run_renew="no"

for cert in $certificates; do

    expired=$(certbot certificates -d $cert 2>&1 | grep 'INVALID: EXPIRED' | wc -l)

    if [ "$expired" -eq "1" ]; then

        echo "$cert:expired"

        # If any certificate is expired, we will at least restart nginx,
	# because it could be a wildcard, or www or even the autodiscover
	run_renew="yes"
	
        if [ "$cert" = "imap.{{ network.domain }}" ]; then
            dovecot_reload="yes"
        elif [ "$cert" = "pop3.{{ network.domain }}" ]; then
            dovecot_reload="yes"
        elif [ "$cert" = "smtp.{{ network.domain }}" ]; then
            postfix_reload="yes"
        elif [ "$cert" = "ldap.{{ network.domain }}" ]; then
            slapd_reload="yes"
        fi
    fi

done

# Renew all the certificates that have expired
if [ "$run_renew" = "yes" ]; then

    # When running as a cron task, wait max
    # an hour before renewing the certificates
    if [ "$context" = "cron" ]; then
	wait=$(perl -e 'print int(rand(3600))')
	sleep $wait
    fi

    # Stop the nginx server
    systemctl stop nginx

    # Run the certificate renewal script,
    # but don't stop the script if anything goes wrong...
    certbot renew -n || /bin/true

    # Start the nginx server
    systemctl start nginx
fi

# Restart the services that need to be restarted
if [ "$dovecot_reload" = "yes" ]; then
    systemctl reload dovecot
fi

if [ "$postfix_reload" = "yes" ]; then
    systemctl reload postfix
fi

if [ "$slapd_reload" = "yes" ]; then
    systemctl restart slapd
fi

if [ "$nginx_running" = "no" ]; then
    systemctl start nginx
fi

