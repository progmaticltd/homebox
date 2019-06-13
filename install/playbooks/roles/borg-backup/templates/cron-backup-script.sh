#!/bin/dash

# Log file path: per location
log_file='/var/log/backup-{{ location.name }}.log'

# Call the global script helper
{% if system.debug %}
/usr/local/sbin/backup --config '{{ location.name }}' --log-file "$log_file" --log-level DEBUG
{% else %}
/usr/local/sbin/backup --config '{{ location.name }}' --log-file "$log_file"
{% endif %}
