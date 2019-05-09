# IMAP clients are using the APPEND verb to store sent emails in the Sent folder.
# However, homebox already send a blind copy to the same user to be directly
# stored in the sent folder, using recipient delimiter and +Sent.
# In this case, this would create a "duplicate" email, with the same Message-ID header.
require [
  "variables",
  "environment",
  "duplicate",
  "imapsieve"
];

{% if mail.import.active %}
# Keep emails imported automatically, trust the user choice or the other server.
if environment :matches "imap.user" "*" {
  set "user" "${1}";
}
if string :matches "${user}" "import" {
  keep;
  stop;
}
{% endif %}

# Discard duplicate messages based on Message-ID in this folder, perhaps a
# client already made a copy in the Sent folder.
# Some email clients keep the same Message-ID when using the feature "edit as new"
# The one second prevent different messages to be deleted.
if duplicate :seconds 1 {
   discard;
}
