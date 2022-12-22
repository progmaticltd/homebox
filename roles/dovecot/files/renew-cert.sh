#!/bin/dash

# Restart dovecot at midnight

if ! cat /var/spool/cron/atjobs/* | grep -c 'systemctl restart dovecot'; then

    echo 'systemctl restart dovecot' | at midnight

fi
