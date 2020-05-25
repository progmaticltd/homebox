# Sieve script to report legitimate email (ham) by moving an email out of the spam folder

require [
  "vnd.dovecot.pipe",
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

if environment :matches "imap.user" "*" {
  set "user" "${1}";
}

if header :matches "From" "*" {
  set "from" "${1}";
}

if header :matches "To" "*" {
  set "to" "${1}";
}

if header :matches "Date" "*" {
  set "date" "${1}";
}

pipe :copy "learn-hamorspam.sh" [ "ham", "${user}", "{$date}", "${from}", "${to}", "${subject}" ];
