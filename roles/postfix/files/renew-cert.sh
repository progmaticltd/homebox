#!/bin/dash

# Refresh the DANE record if needed
/usr/local/sbin/dane-set-record smtp 25

# Restart postfix at midnight
if ! cat /var/spool/cron/atjobs/* | grep -c 'systemctl restart postfix'; then
    echo 'systemctl restart postfix' | at midnight
fi
