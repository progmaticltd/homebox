#!/bin/dash

# Post login script for Dovecot, this block is parsed by the parent script
# Blocking: Yes
# RunAs: Postmaster
# NeedDecryptKey: No
# AlwaysRun: Yes
# Reporting: Yes

# Exit codes
CONTINUE=0

# Check if this is a private IP address
isPrivate=$(ipcalc "$IP" | grep -c "Private Internet")

# Ignore private IP addresses
if [ "$isPrivate" = "1" ]; then
    exit $CONTINUE
fi

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
lastMinute=$((unixtime - 60))
ipSig=$(echo "$IP:$SOURCE" | md5sum | cut -f 1 -d ' ')

# Check if already logged in from this IP
# and the source used (imap/sogo/roundcube)
# in the last minute
# Get the last connection from this IP / source
if [ -f "$connLogFile" ]; then
    lastConnFromThisIP=$(grep "$USER $ipSig" "$connLogFile" | tail -n1 | cut -f 1 -d ' ')

    # Keep the last 100 lines only
    sed -i -e ':a' -e '$q;N;101,$D;ba' "$connLogFile"
fi

# Some clients are opening mutlitple connections on startup
# Send the warning only one time per minute
if [ "0$lastConnFromThisIP" -gt "0$lastMinute" ]; then
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


if [ "$DETAILS" != "" ]; then
    MSG="${MSG}\nDetails:$DETAILS"
fi

# TODO: Use a public service or a customisable URL
MSG="${MSG}\n\nIP Details: https://whatismyipaddress.com/ip/${IP}"

# Send the alert using XMPP
if [ "$USE_XMPP" = "1" ]; then
    xmppOutput=$(echo "$MSG" | sendxmpp -t -f "$xmppConfig" "$MAIL" 2>&1)
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

    # This will be in the external recipient email
    if [ "$xmppOutput" != "" ]; then
        MSG="$MSG\nXMPP output: $xmppOutput"
    fi

    # Send an email alert as well
    subject="Alert from postmaster ($domain)"
    from="postmaster@${domain}"

    echo "$MSG" | mail -r "$from" -s "$subject" "$ALERT_ADDRESS"

fi

exit $CONTINUE
