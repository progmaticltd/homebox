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
ipSig=$(echo "$IP:$SOURCE" | md5sum | cut -f 1 -d ' ')

# Check if already logged in from this IP
# and the source used (imap/sogo/roundcube)
# Get the last connection from this IP / source
if [ -f "$connLogFile" ]; then
    lastLogEntryFromThisIP=$(grep "$USER $ipSig" "$connLogFile" | tail -n1 | cut -f 1 -d ' ')

    # Keep the last 1000 lines only
    sed -i -e ':a' -e '$q;N;1001,$D;ba' "$connLogFile"
fi

# Some clients are opening mutlitple connections on startup
# When status is warning, send the alert only one time per day, IP and source
if [ "0$lastLogEntryFromThisIP" -gt "0$lastDay" -a "$STATUS" = "WARNING" ]; then
    exit
fi

# when the status is DENIED, send the warning once per hour only
# to avoid DoS. At this time, the user should be warned that his
# account is compromised
if [ "0$lastLogEntryFromThisIP" -gt "0$lastHour" -a "$STATUS" = "DENIED" ]; then
    exit
fi

# Add a line to remember this connection has been logged
echo "$unixtime $USER $ipSig" >>"$connLogFile"

domain=$(echo "$MAIL" | cut -f 2 -d '@')
STATUS=$(echo "$STATUS" | tr '[:upper:]' '[:lower:]')

# Check if we can use XMPP to send the alerts
USE_XMPP=0
xmppConfig="/home/users/postmaster/.sendxmpprc"
if [ -x "/usr/bin/sendxmpp" -a -f "$xmppConfig" ]; then
    logger "Using mail and XMPP to send alerts"
    USE_XMPP=1
else
    logger "Using only mail to send alerts"
fi

# Build the message
MSG="IMAP connection ${STATUS}\n"
MSG="${MSG}- User: ${USER} ($MAIL)\n"
MSG="${MSG}- IP Address: ${IP}\n"
MSG="${MSG}- Source: ${SOURCE}\n"
MSG="${MSG}- Final score: ${SCORE}\n"


if [ "$DETAILS" != "" ]; then
    MSG="${MSG}\nDetails:$DETAILS"
fi

# TODO: Use a public service or a customisable URL
MSG="${MSG}\n\nIP Details: https://whatismyipaddress.com/ip/${IP}"

# Send the alert using XMPP
if [ "$USE_XMPP" = "1" ]; then
    xmppOutput=$(echo "$MSG" | sendxmpp -t -f "$xmppConfig" "$MAIL" 2>&1)

    # This will be in the external recipient email
    if [ "$xmppOutput" != "" ]; then
        logger -p user.warning "sendxmpp error when sending warning from postmaster to $MAIL: $xmppoutput"
    fi
fi

# Send the alert by email first. If the user is logged in,
# he will be informed
subject="Alert from postmaster ($domain)"
from="postmaster@${domain}"
echo "$MSG" | mail -r "$from" -s "$subject" "$MAIL"

# Send the alerts to an external / global account
if [ "$ALERT_ADDRESS" != "" ]; then

    # Send the alert using XMPP
    if [ "$USE_XMPP" = "1" ]; then
        # Try to send to the extra recipient if configured
        xmppOutput=$(echo "$MSG" | sendxmpp -t -f "$xmppConfig" "$ALERT_ADDRESS")
    fi

    if [ "$xmppOutput" != "" ]; then
        logger -p user.warning "sendxmpp error when sending warning from postmaster to $ALERT_ADDRESS: $xmppoutput"
    fi

    # Send an email alert as well
    subject="Alert from postmaster ($domain)"
    from="postmaster@${domain}"

    echo "$MSG" | mail -r "$from" -s "$subject" "$ALERT_ADDRESS"

fi

exit $CONTINUE
