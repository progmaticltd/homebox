#!/bin/dash

# Send a notice to the user when the master account has been used to access their mailbox

# Post login script for Dovecot, this block is parsed by the parent script
# Blocking: No
# RunAs: Postmaster
# NeedDecryptKey: No
# Reporting: Yes

# Exit codes
CONTINUE=0

# Ignore when this is not a master user access
if [ "$MASTER_USER" = "" ]; then
    exit $CONTINUE
fi

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="/home/users/postmaster/security"

# The file that will contains the connection logs
connLogFile="$secdir/warnings.log"

# Initialise the environment
unixtime=$(date +%s)
lastHour=$((unixtime - 3600))
connSig=$(echo "$IP:$SOURCE:$STATUS:NOTICE" | md5sum | cut -f 1 -d ' ')

# Check if already logged in from this IP
# and the source used (imap/sogo/roundcube)
# Get the last connection from this IP / source
if [ -f "$connLogFile" ]; then
    lastLogEntryFromThisIP=$(grep "$USER $connSig" "$connLogFile" | tail -n1 | cut -f 1 -d ' ')

    # Keep the last 1000 lines only
    # shellcheck disable=SC2016
    sed -i -e ':a' -e '$q;N;1001,$D;ba' "$connLogFile"
fi

# Some clients are opening multiple connections on startup
# When status is warning, send the alert only one time per hour
if [ "0$lastLogEntryFromThisIP" -gt "0$lastHour" ]; then
    exit
fi

# Add a line to remember this connection has been logged
echo "$unixtime $USER $connSig" >>"$connLogFile"

domain=$(echo "$MAIL" | cut -f 2 -d '@')

# Check if we can use XMPP to send the alerts
USE_XMPP=0
xmppConfig="/home/users/postmaster/.sendxmpprc"
# shellcheck disable=SC2166
if [ -x "/usr/bin/sendxmpp" -a -r "$xmppConfig" ]; then
    logger "Using mail and XMPP to send alerts"
    USE_XMPP=1
else
    logger "Using only mail to send alerts"
fi

# Build the message with all the details
STATUS=$(echo "$STATUS" | tr '[:upper:]' '[:lower:]')

MSG="Your emails are opened by the master user\n"
MSG="${MSG}- IP Address: ${IP}\n"
MSG="${MSG}- Access: ${STATUS}\n"
MSG="${MSG}- Source: ${SOURCE}\n"
MSG="${MSG}- Status: ${STATUS}\n"

# Use duckduckgo to search the IP by default
MSG="${MSG}\n\nIP Details: https://duckduckgo.com/?q=whois+${IP}"

# Send the alert using XMPP
if [ "$USE_XMPP" = "1" ]; then
    xmppOutput=$(echo "$MSG" | sendxmpp -t -f "$xmppConfig" "$MAIL" 2>&1)

    # This will be in the external recipient email
    if [ "$xmppOutput" != "" ]; then
        logger -p user.warning "sendxmpp error when sending warning from postmaster to $MAIL: $xmppOutput"
    fi
fi

# Send the alert by email first. If the user is logged in,
# he will be informed
subject="Alert from postmaster ($domain)"
from="postmaster@${domain}"

# Make sure it is properly displayed in standard mail systems
contentHeader='Content-Type: text/plain; charset="ISO-8859-1"'
alertHeader="X-Postmaster-Alert: Master access notice ($STATUS)"

echo "$MSG" | mail -a "$contentHeader" -a "$alertHeader" -r "$from" -s "$subject" "$MAIL"

exit $CONTINUE
