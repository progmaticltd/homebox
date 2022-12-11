#!/bin/dash

# Parameters: (spam or ham), user, date, from, to, subject
learnType=$1

# Set the host
host="unix:/run/rspamd/controller.sock"

exec /usr/bin/rspamc -v -h "$host" "learn_${learnType}"

exit 0
