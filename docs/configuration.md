
The main configuration file to create is in the config folder. There is an example
named [system-example.yml](config/system-example.yml) ready to copy to customise.

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

```yaml
###############################################################################
# Email related options
mail:
  max_attachment_size: 25   # In megabytes
  autoconfig: true          # Support Thunderbird automatic configuration
  autodiscover: false       # Support MS Outlook automatic configuration (uses https)
  quota:
    default: 1G             # Maximum allowed mailbox size for your users.
                            # The safe maximum value will be automatically computed in a next version.
  discard_duplicates: true  # Discard duplicates messages. It is safe, but you can disable if you are worried
                            # The default timerange is 1h
  antivirus:                # Check inbound and outbound emails for viruses
    active: true            # or false
    action: drop            # Action to do when a virus is found in an email: bounce or drop
                            # be careful, bouncing external emails is a way to expose clamav usage
    send_warnings: false    # Send a warning email to - internal - users who are sending viruses
    quarantine: yes         # Place emails with a virus in quarantine, for further analysis
  impersonate:              # Activate dovecot "master" user feature, ideal for families and communities
    active: false           # https://wiki2.dovecot.org/Authentication/MasterUsers
    master: master          # master user name
    separator: '*'          # Separation char between master user / real user name. I personally use '/'
  #############################################################################
  import:                   # If you have users with "import" email active scripts, set this flag to true
    active: false           # A master user, with reduced rights will be created, to append miported emails
                            # in user's mailboxes.
  #############################################################################
  advanced_features: false  # Use some advanced features that will need the latest version of dovecot
                            # from stretch-backports, like those below.
                            # like sending emails to an international addresses (e.g. andré@homebox.space)
  recipient_delimiter: '+'  # The characters you want to use to split email address from mailbox, i.e.:
                            # when receiving a message to john+lists@example.com, it should go directly to
                            # the 'lists' folder... I personally use '~'

###############################################################################
```

Once again, the file should be self documented.

### Automatic configuration of Thunderbird and Outlook

The two options “autoconfig” and “autodiscover” allows your users to automatically configure their
email parameters in _Mozilla Thunderbird_ and _Microsoft Outlook_. Both requires the creation of two domain
entries, for instance "autoconfig.homebox.space" and "autodiscover.homebox.space"

The later requires the creation of an HTTPS certificate, which is automatically managed when using Gandi.

## Password policies

Password policies are enforced at two levels, when you change your password via the Roundcube webmail
interface, and from the command line, if you are connected through SSH or in the console.

```yaml

# Default password policies for users
passwords_min_length: 8
passwords_max_age: 365 # days
passwords_max_failure: 5
passwords_expire_warning: 7 # days
passwords_require_nonalpha: true

# Keep track of the passwords you have used before.
# They are stored using salted SHA512, which is safe enough.
# If you do not want, set this value to 0
passwords_remember: 12

# Strong system enforcement of passwords
# See: https://www.networkworld.com/article/3198444/linux/the-complexity-of-password-complexity.html
passwords_quality_check: true
passwords_quality_minclass: 3
passwords_quality_maxrepeat: 3
passwords_quality_maxclassrepeat: 4
passwords_quality_lcredit: 1
passwords_quality_ucredit: 1
passwords_quality_ocredit: 3
passwords_quality_dcredit: 1
passwords_quality_difok: 3

```

## System parameters

This section should only be used for development and debugging purposes.

```yaml
###############################################################################
# System related
system:
  release: stretch
  ssl: letsencrypt
  devel: false
  debug: false
```

- Debian version to use: stretch.
- ssl provider to use: letsencrypt by default.
- devel: If you set this value to true, it will have a different behaviour in the deployment.
  This is detailed in the [development](development.md) page.


## DNS automatic update

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
# Once the system is in place, it is possible to use 'limit' for the rule, instead of any.
# It is also possible to use fail2ban, which is installed anyway
firewall:
  ssh:
    from: any
    rule: allow
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

## Roundcube plugins configuration

The plugins in roundcube can be customised as well, although some of them have 
not been thoroughly tested.


```yaml
###############################################################################
# roundcube_install: true
roundcube_plugins:
  - password
  - archive
  - jqueryui
  - markasjunk
  - newmail_notifier
  - autologon
  - subscriptions_option
  - emoticons
  - new_user_identity
  - managesieve
  - contextmenu
  - thunderbird_labels
```

```yaml
###############################################################################
# Dictionaries to install in the system
dictionaries:
  - name: English
    id: en
  - name: French
    id: fr
  - name: Spanish
    id: es
```

Other plugins available include:

- keyboard_shortcuts
- dkimstatus
- hide_blockquote
- enigma
- zipdownload
- new_user_dialog
- additional_message_headers
- acl
- vcard_attachments
- database_attachments
- debug_logger
- filesystem_attachments
- help
- hide_blockquote
- http_authentication
- show_additional_headers
- squirrelmail_usercopy
- userinfo
- virtuser_file
- virtuser_query

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

