# Sieve script executed before for user 
require ["fileinto","imap4flags"];

# Move automatically copied emails to the sent folder
# And mark them as read
if header :contains "Delivered-To" "{{ mail.recipient_delimiter}}Sent"
{
  setflag "\\Seen";
  fileinto "Sent";
}
