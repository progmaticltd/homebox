# Global sieve script executed before for user
require [ "imap4flags" ];

# The label $1 is "Important" in Thunderbird, keep it
if true {
  setflag "\\Flagged";
  addflag "$label1";
}
