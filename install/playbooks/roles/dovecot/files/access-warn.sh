#!/bin/dash

# Post login script for Dovecot, this block is parsed by the parent script
# Blocking: No
# RunAs: Postmaster
# NeedDecryptKey: No
# AlwaysRun: Yes
# Reporting: Yes

# Check if this is a private IP address
isPrivate=$(ipcalc "$IP" | grep -c "Private Internet")

# Ignore private IP addresses
if [ "$isPrivate" = "1" ]; then
    exit
fi

# Ignore normal connections
if [ "$STATUS" = "OK" ]; then
    exit
fi

configFile=/home/users/postmaster/.sendxmpprc
domain=$(echo "$MAIL" | cut -f 2 -d '@')
STATUS=$(echo "$STATUS" | tr '[:upper:]' '[:lower:]')

# Build the message
MSG="Message from postmaster@${domain}:\n"
MSG="${MSG}IMAP connection ${STATUS}\n"
MSG="${MSG}- User: ${USER} ($MAIL)\n"
MSG="${MSG}- IP Address: ${IP}\n"
MSG="${MSG}- Source: ${SOURCE}\n"
MSG="${MSG}- Reason: ${REASON}"

if [ "${DETAILS}" != "" ]; then
    MSG="${MSG}\n${DETAILS}"
fi

MSG="${MSG}\nIP Details: https://whatismyipaddress.com/ip/${IP}"

# Send to the original user
xmppOutput=$(echo "$MSG" | sendxmpp -t -f "${configFile}" "$MAIL" 2>&1)

if [ "$ALERT_ADDRESS" = "" ]; then
    ALERT_ADDRESS="andy@rodier.me"
fi

if [ "$ALERT_ADDRESS" != "" ]; then

    MSG="$MSG\nXMPP output: $xmppOutput"
    
    # Send an email alert as well
    subject="Alert from postmaster ($domain)"
    from="postmaster@${domain}"
    echo "$MSG" | mail -r "$from" -s "$subject" "$ALERT_ADDRESS"
    
    # Send to the extra recipient if configured
    # echo "$MSG" | sendxmpp -t -f "${configFile}" "$ALERT_ADDRESS"
fi

exit 0
