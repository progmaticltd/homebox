#!/bin/dash

# Restart nginx at midnight

if ! cat /var/spool/cron/atjobs/* | grep -c 'systemctl restart nginx'; then

    echo 'systemctl restart nginx' | at midnight

fi
