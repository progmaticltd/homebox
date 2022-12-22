#!/bin/dash

# Restart ejabberd at midnight

if ! cat /var/spool/cron/atjobs/* | grep -c 'systemctl restart ejabberd'; then

    echo 'systemctl restart ejabberd' | at midnight

fi
