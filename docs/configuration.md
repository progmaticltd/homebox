
The main configuration file to create is in the config folder. There is an example
named [system-example.yml](config/system-example.yml) ready to copy to customise.

There is also a configuration file [defaults.yml](config/defaults.yml).
This file contains all the possible options, and **is merged with your
configuration** on deployment. Therefore, you can override any default
value without having to copy entire branches.

```sh
cd config
cp system-example.yml system.yml
```

The system configuration file is a complete YAML configuration file containing all your settings:

- Network information, specifically your domain name.
- User and group details, like email addresses and aliases.
- Email parameters, like maximum attachment size, antivirus options, etc.
- Some password policies, like minimum length and complexity.
- Webmail settings (roundcube).
- Low level system settings, mainly used during the development phase.
- DNS update credentials (Gandi API key).
- Firewall policies, especially SSH access.
- Security settings, like AppArmor activation.
- Backup configuration details

The most important settings are the first two sections, the others can be left to their default values.

## Network details

Every network subdomain entries, email addresses, etc... will include the domain name:

```yaml

###############################################################################
# Domain and hostname information
network:
  domain: homebox.space
  hostname: mail.homebox.space

```

The hostname is important, use the real one. If you used the preseed configuration,
it should be just mail and your network domain.

## User list

The other information you need to fill first is the user list.

```yaml

###############################################################################
# Users
# List of users to create in the system
users:
- uid: john
  cn: John Doe
  first_name: John
  last_name: Doe
  mail: john.doe@example.com
  password: 'xIlm*uu7'
  aliases:
    - john@homebox.space
    - johny@homebox.space
    - johny-be-good@homebox.space
- uid: jane
  cn: Jane Doe
  first_name: Jane
  last_name: Doe
  mail: jane.doe@example.com
  password: 'Tlwril!8'
  aliases:
    - jane@homebox.space
```

The file format should be self explanatory. For complex passwords, use quotes, like " or '

The email aliases are the other email addresses that belongs to the same user.

You can also [import accounts from other platforms](external-accounts.md).

## Email options

Here an example of the email options you can override:

```yaml

###############################################################################
# Email related options
mail:
  max_attachment_size: 25   # In megabytes
  autoconfig: true          # Support Thunderbird automatic configuration
  autodiscover: false       # Support MS Outlook automatic configuration (uses https)
  quota:
    default: 1G             # Maximum allowed mailbox size for your users.
```

The most up to date options are in the [defaults.yml](config/defaults.yml) configuration
file.

## DNS automatic update

If you are using Gandi, you can automate your DNS records update.

```yaml
###############################################################################
# Gandi automatic DNS update
# Your Gandi Key should be 24 characters long, e.g. zaNGbUVIvi1KbYb6PPMdiQLh
dns:
  update: true          # Automatic update of your DNS server
  test: true            # test mode: does not activate the DNS zone straight
  add_wildcard: false   # Create a wildcard entry to redirect all traffic to your box
  gandi:
    handle: JD123-GANDI
    key: zaNGbUVIvi1KbYb6PPMdiQLh
```

## Firewall configuration

```yaml
###############################################################################
# Once the system is in place, it is possible to use 'limit' for the rule,
# instead of allow. It is also possible to use fail2ban, which is installed anyway
# You can have as many sources as you want, with a comment to easily keep track
# of your rules
firewall:
  ssh:
    - src: 192.168.1.0/24
      comment: 'Allow from the LAN'
```

## Security options

```yaml
###############################################################################
# Extra security values
security:
  auto_update: true
  app_armor: true
```

## Webmail

By default, the installation script installs Roundcube, but you can disable it if you want.
One of the next version will propose Sogo as well.

```yaml
###############################################################################
# Install a webmail, or not...
webmail:
  install: true
  type: roundcube
```

## Backup configuration

By default, there is a backup of the whole home partition / folder.
The detailed instructions are on the [backup documentation](backup.md) page.
Here a quick overview of the configuration

```yaml

###############################################################################
# Backup configuration
# You can have multiple backup configuration:
# remote (ssh or samba) and local directory
# All backups will be encrypted
# Compression: See borg documentation

backup:
  install: true
  type: borgbackup
  locations:
  - name: local
    url: dir:///va/backups/homebox
    active: yes                      # The backup is currently active
    frequency: daily                 # Run the backup every day
    keep_daily: 3                    # Keep the last three days locally
    compression: lz4                 # Compression scheme to use (lz4 by default)
  - name: router
    url: ssh://fw.office.pm:/home/backup/homebox
    active: yes                      # The backup is currently active
    frequency: daily                 # Run the backup every day
    keep_daily: 7                    # Keep the last seven days (default value)
    keep_weekly: 4                   # Keep the last four weeks (default value)
    keep_monthly: 6                  # Keep the last six months (12 by default)
    compression: lz4                 # Compression scheme to use (lz4 by default)
  - name: nas
    url: smb://backup:giuwh97kwerr@ftp.office.pm:/home/backup/homebox
    active: yes                      # The backup is currently active
    frequency: weekly                # Run the backup every week
    keep_weekly: 4                   # Keep the last four weeks (default value)
    keep_monthly: 6                  # Keep the last six months (12 by default)
    compression: zlib,6              # Compression scheme to use (lz4 by default)
```
