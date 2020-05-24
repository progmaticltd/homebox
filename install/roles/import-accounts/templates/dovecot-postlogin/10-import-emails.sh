#!/bin/dash

# By default, read the encryption key stored in the homebox folder
# and call the script as a user, that will be able to decrypt
# credentials to import data

decryptKeyFile='/etc/homebox/system-key'

if [ -f "$decryptKeyFile" ]; then

    # Decrypt the configuration files with this key
    decryptKey=$(cat $decryptKeyFile)

    # Drop privileges, and run the email import script as the user, in background
    su $USER -c "DECRYPT_KEY='$decryptKey' /usr/local/bin/import-emails" &
fi
