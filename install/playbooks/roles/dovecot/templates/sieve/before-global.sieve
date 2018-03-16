# Sieve script executed before for user 
require ["fileinto","imap4flags"];

# Move automatically copied emails to the sent folder
# And mark them as read
if header :contains "Delivered-To" "+sent"
{
  setflag "\\Seen";
  fileinto "Sent";
}
