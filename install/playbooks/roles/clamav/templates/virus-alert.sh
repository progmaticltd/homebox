#!/bin/bash

# Initialise the log file, and redirect stdout
logfile="/var/log/clamav/clamsmtp.log"
exec 1>>$logfile

# Initialise the errors file, and redirect stderr
errorfile="/var/log/clamav/clamsmtp-errors.log"
exec 2>>$errorfile

now=$(date +'%Y-%m-%d %H:%m:%s')

# If the sender is in the internal domain, send an email
if [[ "${SENDER}" =~ "@{{ network.domain }}" ]]; then

# Will be in the logs
	echo "${now}: Virus found for ${RECIPIENTS}, sending a warning email to sender ${SENDER}."

    # email subject
    subject="Virus detected: ($VIRUS)"

    # Email body
    body="An email coming from your email address (${SENDER}) has been found with a virus.\n
\n
- The virus is identified by ClamAV as '${VIRUS}'.\n
- The final recipient(s) were ${RECIPIENTS}\n
\n\n
The email has been discarded, check your workstation for viruses!
\n\n\n
-- \n
The Postmater"

    # Send the email
    echo -e ${body} | mail -a 'X-Postmaster-Alert: virus' \
			   -r 'postmaster@{{ network.domain }}' \
			   -s "${subject}" -- $SENDER
else
    echo "${now}: Virus found from ${SENDER} to ${RECIPIENTS}, dropped: not in domain {{ network.domain }}."
fi
