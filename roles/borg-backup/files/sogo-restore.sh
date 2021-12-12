#!/bin/sh

if [ "$USER" != "sogo" ]; then
    echo "You need to run this service as the sogo user"
    exit 1
fi

last_backup=$(ls -1t /var/backups/sogo/ | head -n 1)

if [ "$last_backup" = "" ]; then
    echo "No backup to restore"
    exit
fi

if [ "$last_backup" = "restored" ]; then
    echo "Last backup already restored"
    exit
fi


# Get the list of users
users_list=$(getent -s ldap passwd | cut -f 1 -d : | tr '\n' ' ')

# Start in the last backup directory
cd /var/backups/sogo/$last_backup/

for user in $users_list; do

    # Skip non-existing backup
    test -d "$user" || continue

    # Restore the backup for this user
    sogo-tool restore -F ALL . $user

done

# Ensure the restoration of this backup
# does not happen again
touch /var/backups/sogo/restored
