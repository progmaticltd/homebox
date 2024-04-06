#!/bin/dash

# Parameters: (spam or ham)
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
    logger "Cannot open socket file for writing"
    exit $socket_error
fi

if ! /usr/bin/rspamc -v -h "$socket" "learn_${type}"; then
    logger "Error when running rspamc client"
    exit $runtime_error
fi

exit $success
