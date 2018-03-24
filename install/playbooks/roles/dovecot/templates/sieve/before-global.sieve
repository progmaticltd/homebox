# Global sieve script executed before for user 
require [ "fileinto", "imap4flags", "duplicate" ];

# Move automatically copied emails to the sent folder
# And mark them as read
if header :contains "Received" "{{ mail.recipient_delimiter}}Sent"
{
  setflag "\\Seen";
  fileinto "Sent";
}

# Remove duplicate messages in the Sent folder
if duplicate :seconds 3600 :header "message-id"
{
  discard;
}
