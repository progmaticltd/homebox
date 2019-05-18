# Default security settings

The default settings are

- Automatically install security updates using unattended upgrades.
- Send alerts to the postmaster.
- Force root SSH login to use public key cryptography, and not a password.
- Disable the root password.

```yaml
###############################################################################
# Extra security values
security_default:
  auto_update: true                             # Install security updates automatically, using unattended-upgrades
  ssh_disable_root_access_with_password: true   # Force SSH authentication to use public / private key
  ssh_disable_root_access: false                # At the end of the installation, completely disable remote
                                                # root access via SSH and force the use of sudo for the administrators
  lock_root_password: true                      # Disable console root access by locking root password.
  alerts_email:
    - 'admin@{{ network.domain }}'
  # various options when luks is installed
  luks:
    yubikey: false

```

# Options details

## Automatic security updates

By default, automatic security updates are installed, using the
[unattended-upgrades](https://wiki.debian.org/UnattendedUpgrades) package.

The changes are sent to the postmaster by default, using the recipient(s) defined in alerts_email variable.

## Root access

The root account is locked by default, which means only SSH access is possible. However, you can define administrators
of the system, and use the `sudo` command to become root.

## Defining administrators

This is done by setting a flag `sudo: true` for the users you want to grant administrator's rights, for instance:

```yaml
# list of users
users:
- uid: john
  cn: John Doe
  first_name: John
  last_name: Doe
  mail: john.doe@example.com
  password: 'xIlm*uu7'
  # This user will be part of the sudo group
→ sudo: true
```

## Grant some users remote access

This is done by adding a public key to the user definition, for instance:

```yaml
# list of users
users:
- uid: john
  cn: John Doe
  first_name: John
  last_name: Doe
  mail: john.doe@example.com
  password: 'xIlm*uu7'
  # Allow remote access using SSH
→ ssh_key:
    type: ecdsa-sha2-nistp384
    comment: john@homebox
    data: >-
      AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBE+E0hiYkPywn43g2J5s5t8mGq
      muUwObvFN05lCYpEQYv002lMeZEcD9rN80ZBGXJ49J0pfHmuRYScHIt3SjP7Eau3UrGebHvXSBzqPI
      xcLmuv8NO2siwhqWmZfvrXEWlQ==
```

If you are giving one user remote both sudo and remote access, you can then completely disable root SSH login:

```yaml
# Security settings
security:
→ ssh_disable_root_access_with_password: true
→ ssh_disable_root_access: true
→ lock_root_password: true

```

## Yubikey

If your system is encrypted with LUKS, you can use a [Yubikey](https://en.wikipedia.org/wiki/YubiKey) to decrypt the
main disk. This will be the simplest and safest option to decrypt your main drive.

```yaml
# Security settings
security:
  …
→ luks:
    yubikey: true

```

Once the system is installed, run the provided script to "enroll" your key:

```sh

root@osaka:~ # yubikey-enroll.sh
This script will Register your Yubikey to decrypt the main drive.
Plug your Yubikey that will be used to decrypt the hard drive. Continue (y/n) ?
y
Partition: /dev/sda5
Key Slot 0: ENABLED
Key Slot 1: DISABLED
Key Slot 2: DISABLED
Key Slot 3: DISABLED
Key Slot 4: DISABLED
Key Slot 5: DISABLED
Key Slot 6: DISABLED
Key Slot 7: ENABLED
The key will be registered in the slot 1

```

The script will automatically choose a free slot.  

