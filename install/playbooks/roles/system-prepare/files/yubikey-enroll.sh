#!/bin/sh

part=$(blkid | grep crypto_LUKS | cut -f 1 -d ':')
slot=$(cryptsetup luksDump "$part" | grep DISABLED | sed -r 's/^[^0-9]+([0-9])[^0-9]+$/\1/gi' | head -n 1)

# Run the interactive command
echo "This script will Register your Yubikey to decrypt the main drive."
read -r cont -p "Plug your Yubikey that will be used to decrypt the hard drive. Continue (y/n) ?"

if [ "$cont" != "y" ]; then
    echo "Operation cancelled"
    exit 1;
fi

# Display the informaton of the partition
echo "Partition: $part"
cryptsetup luksDump "$part" | grep "^Key Slot"
echo "The key will be registered in the slot ${slot}"

# Run the command
yubikey-luks-enroll -d "$part" -s "$slot"
