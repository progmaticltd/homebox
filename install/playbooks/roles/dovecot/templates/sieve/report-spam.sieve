# Sieve script to report jumk email (spam) by moving an email into the spam folder

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

pipe :copy "learn-hamorspam.sh" [ "spam", "${user}", "{$date}", "${from}", "${to}", "${subject}" ];
