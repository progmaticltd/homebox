# Global sieve script that removed duplicated messages
require [ "duplicate" ];

# It might be possible to send a warning to the user if its email client
# is configured to save a copy of sent emails in the "Sent" folder

# Remove duplicate messages when importing emails
if duplicate :seconds 60 :header "message-id"
{
  discard;
}
