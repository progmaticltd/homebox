#!/bin/dash

# Restart postfix at midnight

if ! cat /var/spool/cron/atjobs/* | grep -c 'systemctl restart postfix'; then

    echo 'systemctl restart postfix' | at midnight

fi
