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

## Locking root access

The root account is locked by default, which means only SSH access is possible. However, if you have defined
administrators, you can now activate the `sudo` command to become root for these accounts and completely disable root
SSH login:

```yaml
# Security settings
security:
  ssh_disable_root_access_with_password: true
  ssh_disable_root_access: true
  lock_root_password: true
```
