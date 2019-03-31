# IMAP clients are using the APPEND verb to store sent emails in the Sent folder.
# However, homebox already send a blind copy to the same user to be directly
# stored in the sent folder, using recipient delimiter and +Sent.
# Emails appended by IMAP clients to the sent folder should be discarded.
require [
  "imap4flags",
  "variables",
  "environment",
  "imapsieve"
];

# Keep the emails sent from the platform (e.g. should match *+Sent)
# This is normally not necessary, as bcc'ed emails are filtered by
# the previous "before-global" sieve filter.
# It is kept here in case we would copy sent emails in the sent folfer
# manually, for instance after a backup
if header :matches "Delivered-To" "*{{ mail.recipient_delimiter[0] }}Sent" {
  keep;
  stop;
}

{% if mail.import.active %}
# Keep emails imported automatically
if environment :matches "imap.user" "*" {
  set "user" "${1}";
}
if string :matches "${user}" "*{{ mail.import.username }}*" {
  keep;
  stop;
}
{% endif %}

# Keep messages marked as "not read", this will be useful to force the import
# of messages from another account. Mark them as read, though.
if not hasflag "\\Seen" {
  setflag "\\Seen";
  keep;
  stop;
}

# When importing sent messages from another account,
# the from email address can be another domain
# It might be possible to send a warning to the user if its email client
# is configured to save a copy of sent emails in the "Sent" folder.
# Discard the emails for now.
# TODO: Check if this is working with automatic emails import
discard;
