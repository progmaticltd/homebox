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

domain=$(echo "$MAIL" | cut -f 2 -d '@')
STATUS=$(echo "$STATUS" | tr '[:upper:]' '[:lower:]')

# Check if we can use XMPP to send the alerts
USE_XMPP=0
xmppConfig="/home/users/postmaster/.sendxmpprc"
if [ -x "/usr/bin/sendxmpp" ] && [ -f "$xmppConfig" ]; then
    logger "Using mail and XMPP to send alerts"
    USE_XMPP=1
else
    logger "Using only mail to send alerts"
fi

# Build the message
MSG="Message from postmaster@${domain}:\n"
MSG="${MSG}IMAP connection ${STATUS}\n"
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
