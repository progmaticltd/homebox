#!/bin/dash

# Parameters: (spam or ham), user, date, from, to, subject
type=$1

# Error codes
success=0
param_error=10
socket_error=20
runtime_error=30

# rspamd socket to use
socket="/run/rspamd/controller.sock"

if [ "$type" != "spam" ] && [ "$type" != "ham" ]; then
    logger "Invalid type parameter for ham or spam: '$type'"
    exit $param_error
fi

if [ ! -w "$socket" ]; then
    echo "Cannot open socket file for writing"
    exit $runtime_error
fi

if ! /usr/bin/rspamc -v -h "$socket" "learn_${type}"; then
    echo "Error when running rspamc client"
    exit $runtime_error
fi

exit $success
