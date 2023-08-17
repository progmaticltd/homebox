#!/bin/dash

# Ensure the drive is mounted
ls /mnt/backup/{{ location.name }}

if ! mountpoint -q /mnt/backup/{{ location.name }}; then
    echo "The backup location {{ location.name }} is not mounted"
    exit 1
fi

# Call the global script helper
{% if system.debug %}
/usr/local/sbin/homebox-backup --config '{{ location.name }}' --log-level DEBUG
{% else %}
/usr/local/sbin/homebox-backup --config '{{ location.name }}'
{% endif %}
