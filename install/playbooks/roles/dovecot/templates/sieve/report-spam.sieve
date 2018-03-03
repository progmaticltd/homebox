# Sieve script to report spam by moving an email into the spam folder

require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];

if environment :matches "imap.email" "*" {
  set "email" "${1}";
}

pipe :copy "learn-spam.sh" [ "${email}" ];
