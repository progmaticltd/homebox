#!/bin/sh

# To activate the antispam learning feature, replace this script
# using an antispam third party package, for instance, rspamd.

# This script will be called with the first argument "ham" or "spam"
# - "spam" will be passed when moving an email to the Junk folder,
# - "ham" will be passed when moving an email out of the Junk folder,
#   except if the email is moved to the Trash folder.

exit 0
