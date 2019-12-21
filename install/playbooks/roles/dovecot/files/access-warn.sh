#!/bin/dash

# Post login script for Dovecot, this block is parsed by the parent script
# Blocking: No
# RunAs: Postmaster
# NeedDecryptKey: No
# Reporting: Yes

# Exit codes
CONTINUE=0

# Ignore normal connections
if [ "$STATUS" = "OK" ]; then
    exit $CONTINUE
fi

# Security directory for the user, where the connection logs are saved
# and the custom comfiguration overriding
secdir="/home/users/postmaster/security"

# The file that will contains the connection logs
connLogFile="$secdir/warnings.log"

# Initialise the environment
unixtime=$(date +%s)
lastDay=$((unixtime - 86400))
lastHour=$((unixtime - 3600))
connSig=$(echo "$IP:$SOURCE:$STATUS" | md5sum | cut -f 1 -d ' ')

DOMAIN=$(sed -En 's/DOMAIN=(.*)/\1/p' /etc/homebox/main.cf)
EMAIL_ADDRESS="$ORIG_USER@$DOMAIN"

# Check if already logged in from this IP
# and the source used (imap/sogo/roundcube)
# Get the last connection from this IP / source
if [ -f "$connLogFile" ]; then
    lastLogEntryFromThisIP=$(grep "$ORIG_USER $connSig" "$connLogFile" | tail -n1 | cut -f 1 -d ' ')

    # Keep the last 1000 lines only
    # shellcheck disable=SC2016
    sed -i -e ':a' -e '$q;N;1001,$D;ba' "$connLogFile"
fi

# Some clients are opening mutlitple connections on startup
# When status is warning, send the alert only one time per day, IP and source
# shellcheck disable=SC2166
if [ "0$lastLogEntryFromThisIP" -gt "0$lastDay" -a "$STATUS" = "WARNING" ]; then
    exit
fi

# when the status is DENIED, send the warning once per hour only
# to avoid DoS. At this time, the user should be warned that his
# account is compromised
# shellcheck disable=SC2166
if [ "0$lastLogEntryFromThisIP" -gt "0$lastHour" -a "$STATUS" = "DENIED" ]; then
    exit
fi

STATUS=$(echo "$STATUS" | tr '[:upper:]' '[:lower:]')

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
MSG="IMAP connection ${STATUS}\n"
MSG="${MSG}- User: ${ORIG_USER} ($EMAIL_ADDRESS)\n"
MSG="${MSG}- IP Address: ${IP}\n"
MSG="${MSG}- Source: ${SOURCE}\n"

# Add the final score when requested
if [ "$DISPLAY_SCORE" = "YES" ]; then
    MSG="${MSG}- Final score: ${SCORE} points\n"
fi

if [ "$DETAILS" != "" ]; then
    MSG="${MSG}\nDetails:$DETAILS"
fi

# Use duckduckgo to search the IP by default
MSG="${MSG}\n\nIP Details: https://duckduckgo.com/?q=whois+${IP}"

# Send the alert using XMPP
if [ "$USE_XMPP" = "1" ]; then
    xmppOutput=$(echo "$MSG" | sendxmpp -t -f "$xmppConfig" "$ORIG_USER" 2>&1)

    # This will be in the external recipient email
    if [ "$xmppOutput" != "" ]; then
        logger -p user.warning "sendxmpp error when sending warning from postmaster to $EMAIL_ADDRESS: $xmppOutput"
    fi
fi

# Send the alert by email to the user first. This is mainly useful if the connection is denied.
subject="Alert from postmaster ($DOMAIN)"
from="postmaster@$DOMAIN"

# Make sure it is properly displayed in standard mail systems
contentHeader='Content-Type: text/plain; charset="ISO-8859-1"'
alertHeader="X-Postmaster-Alert: IMAP access $STATUS"

echo "$MSG" | mail -a "$contentHeader" -a "$alertHeader" -r "$from" -s "$subject" "$EMAIL_ADDRESS"

# Now, send the alert using XMPP, to the user account.
if [ "$USE_XMPP" = "1" ]; then
    # Try to send to the extra recipient if configured
    xmppOutput=$(echo "$MSG" | sendxmpp -t -f "$xmppConfig" "$EMAIL_ADDRESS")

    if [ "$xmppOutput" != "" ]; then
        logger -p user.warning "sendxmpp error when sending warning from postmaster to $ALERT_ADDRESS: $xmppOutput"
    fi
fi

# Send the alerts to an external / global account
if [ "$ALERT_ADDRESS" != "" ] && [ "$ALERT_ADDRESS" != "$EMAIL_ADDRESS" ]; then

    # Send an email alert as well
    subject="Alert from postmaster ($DOMAIN)"
    from="postmaster@$DOMAIN"

    echo "$MSG" | mail -a "$contentHeader" -a "$alertHeader" \
        -r "$from" -s "$subject" "$ALERT_ADDRESS"
fi

# Add a line to remember this connection has been logged
echo "$unixtime $ORIG_USER $connSig" >>"$connLogFile"

exit $CONTINUE
