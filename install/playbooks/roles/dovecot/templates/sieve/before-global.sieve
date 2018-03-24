# Global sieve script executed before for user 
require [
  "fileinto",
  "imap4flags",
  "envelope",
  "duplicate",
  "variables"
];

# {% if mail.discard_duplicates %}
# Remove duplicate messages sent from mailing lists
if duplicate :seconds 3600 :header "message-id"
{
  discard;
}
# {% endif %}

# Move automatically copied emails to the sent folder
# And mark them as read
if header :contains "Received" "{{ mail.recipient_delimiter}}Sent"
{
  setflag "\\seen";
  fileinto "Sent";
}

# When using the internal LMTP, these tests are needed:
# 1 - Get from and to,
# 2 - Check if to contains +Sent, and mark the message as read
if envelope :matches "from" "*@{{ network.domain }}" {
  set "from" "${1}";
} else if envelope :matches "to" "*@{{ network.domain }}" {
  set "to" "${1}";
}
if string :is "${from}{{ mail.recipient_delimiter }}Sent" "${to}" {
  setflag "\\seen";
}
