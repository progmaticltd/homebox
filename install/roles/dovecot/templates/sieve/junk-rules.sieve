# Mark messages moved in the junk folder as seen

require [
  "imap4flags",
  "imapsieve"
];

setflag "\\Seen";
