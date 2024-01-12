# Sieve script to report legitimate email (ham) by moving an email out of the spam folder

require [
  "vnd.dovecot.pipe",
  "vnd.dovecot.execute",
  "copy",
  "imapsieve",
  "environment",
  "variables"
  ];

if environment :matches "imap.mailbox" "*" {
  set "mailbox" "${1}";
}

# Do not run the script when deleting Junk
if string :is "${mailbox}" "Trash" {
  stop;
}

# Do not report ham if the flag is not set
if header :contains "X-Spam" "No" {
  stop;
}

# Mark the message as not spam
execute :pipe "learn-hamorspam.sh" [ "ham" ];
