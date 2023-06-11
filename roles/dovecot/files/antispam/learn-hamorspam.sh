#!/bin/dash

# Parameters: (spam or ham), user, date, from, to, subject
type=$1

# Error codes
success=0
param_error=10
runtime_error=20

if [ "$type" != "spam" ] && [ "$type" != "ham" ]; then
    logger "Invalid type parameter for ham or spam: '$type'"
    exit $param_error
fi

# rspamd socket to use
host="unix:/run/rspamd/controller.sock"

if ! /usr/bin/rspamc -v -h "$host" "learn_${type}"; then
    logger "Error when running rspamc client"
    exit $runtime_error
fi

exit $success
