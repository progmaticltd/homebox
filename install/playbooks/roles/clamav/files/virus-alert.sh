#!/bin/dash

# This script is called when a virus has been sent from one of the user
# in the domain.

now=$(date --rfc-3339=seconds)

# Get IP address details
hostname=$(hostname)
domain=$(hostname -f | sed "s/$hostname\.//g")
internal=$(echo "${SENDER}" | grep "${domain}" | wc -l)

logfile=/var/log/clamsmtp/virus-alerts.log

if [ "$internal" = "1" ]; then

    # Will be in the logs
    echo "${now}: Virus found from ${SENDER}, sending an email to the sender." >>${logfile}

    # Get the email subject from the default template
    subject="$(head -n 1 /etc/clamsmtp/virus-alert-default.eml)"

    # Flaten the list of recipients
    RECIPIENTS_FLAT=$(echo "${RECIPIENTS}" | tr '\n' ';' | sed 's/;$//')

    # Get the type of IP address
    IP_PRIVATE=$(ipcalc -n -c ${REMOTE} | grep 'Private' | wc -l)

    # Add more details about the IP address to the email
    if [ "${IP_PRIVATE}" = "1" ]; then
	mac=$(cat /proc/net/arp | grep "${REMOTE}" | sed 's/\s\+/|/g' | cut -d '|' -f 4)
	IP_DETAILS="MAC address: ${mac}"
    else
	IP_DETAILS="https://getmyipaddress.org/ipwhois.php?ip=${REMOTE}"
    fi

    # Parse the body and send the email alert
    tail -n +3 /etc/clamsmtp/virus-alert-default.eml | \
	sed "s/{SENDER}/${SENDER}/g" | \
	sed "s/{VIRUS}/${VIRUS}/g" | \
	sed "s/{REMOTE}/${REMOTE}/g" | \
	sed "s|{IP_DETAILS}|${IP_DETAILS}|g" | \
	sed "s/{RECIPIENTS}/${RECIPIENTS_FLAT}/g" | \
	sed "s/;/\n  - /" | \
	mail -a 'X-Postmaster-Alert: virus' \
	     -r 'postmaster@homebox.space' \
	     -b 'postmaster@homebox.space' \
	     -s "${subject}" -- ${SENDER}

else
    echo "${now}: Virus from ${SENDER} at ${REMOTE} to ${RECIPIENTS}; dropped." >>${logfile}
fi
