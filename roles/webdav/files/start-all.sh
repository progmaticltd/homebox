#!/bin/sh

# Wait for the system to be fully started
set -e

# Load all the ldap users
attempt=0
nb_users=$(getent -s ldap passwd | wc -l)

# Wait for the ldap server to return the users
while [ "$nb_users" -eq 0 ] && [ "$attempt" -lt 10 ]; do

    sleep 5
    nb_users=$(getent -s ldap passwd | wc -l)
    attempt=$((attempt+1))

done

logger "Found $nb_users ldap users after $attempt attempts."

users=$(getent -s ldap passwd | cut -f 1 -d ":")

for user in $users; do

    try=1

    while [ "$try" -le 10 ]; do

        if loginctl enable-linger "$user"; then
            logger "Successfully activated linger for user $user ($try/10)"
            break
        else
            sleep 1
            try=$((try + 1))
            continue
        fi

        logger "Failed to activate linger for user $user"

    done

done
