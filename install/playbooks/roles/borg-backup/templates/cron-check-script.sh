#!/bin/dash

# Log file path: per location
log_file='/var/log/backup-check-{{ location.name }}.log'

# Call the global script helper to verify the data
{% if system.debug %}
/usr/local/sbin/backup --action check-data --config '{{ location.name }}' --log-file "$log_file" --log-level DEBUG
{% else %}
/usr/local/sbin/backup --action check-data --config '{{ location.name }}' --log-file "$log_file"
{% endif %}
