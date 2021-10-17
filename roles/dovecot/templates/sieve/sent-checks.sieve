# IMAP clients are using the APPEND verb to store sent emails in the Sent folder.
# However, homebox already send a blind copy to the same user to be directly
# stored in the sent folder, using recipient delimiter and +Sent.
# In this case, this would create a "duplicate" email, with the same Message-ID header.
require [
  "imapsieve",
  "include"
];

# The pre-sent-checks sieve script is created during email importation.
# During this phase only, emails can be appended to the sent folder.
# Once the importation is finished, the script is removed and no emails
# can be appended to the sent folder again.
# FIXME: Does not work on Bullseye
# include :personal :optional "pre-sent-checks";

# This script is only called when the mail client copies emails to the sent folder.
# This should not be done as the emails are copied automatically using the BCC address.
discard;
