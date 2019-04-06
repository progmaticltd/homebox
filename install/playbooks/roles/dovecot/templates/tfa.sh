#!/bin/sh

# Basic TFA
# This script is run as the current logged in user.
# It receives a decryption key as an environment variable,
# to decrypt the account emails import configuration files
# The next version may use user's GPG keys

# Exemple of the environment variables received from Dovecot login script:
# USERDB_KEYS=HOME UID GID MAIL AUTH_TOKEN
# USER=andre
# MAIL=/var/mail/andre
# HOME=/home/users/andre
# LOGNAME=andre
# PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
# UID=1001
# GID=1001
# LANG=en_GB.UTF-8
# LANGUAGE=en_GB:en
# SHELL=/bin/dash
# PWD=/run/dovecot
# LOCAL_IP=192.168.33.250
# IP=192.168.33.39
# AUTH_TOKEN=bd254f9a87e06dec68ce1bb7ee75f14690b45aee
# DECRYPT_KEY=cIy29nzfAnQCxU8v84Q2jTKAyETmf2Cu

# If remote IP is 127.0.0.1, exit

if [ "${IP}" = "127.0.0.1" ]; then
    exit 0
fi

# Create the security directory if does not exists
secdir="${HOME}/mails/security"
conlog="${secdir}/connections.log"
now=$(date +%s)

# Create the security directory for the user
test -d "${secdir}" || mkdir "${secdir}"

# Create the file if it not exists
test -f "${conlog}" || touch "${conlog}"

# First time login from this IP address?
count=$(grep -c "${IP}" "${conlog}")


# Already logged in from this IP
if [ "${count}" != "0" ]; then
    exit 0
fi

# Add the IP to the list
echo "${now} ${IP}" >> "${conlog}"


