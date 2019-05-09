#!/bin/dash

# Parameters: (spam or ham), user, date, from, to, subject
learnType=$1

# Set the host
host="localhost:{{ 2 + (mail.antispam.port | int) }}"

exec /usr/bin/rspamc -v -h "$host" "learn_${learnType}"

exit 0
