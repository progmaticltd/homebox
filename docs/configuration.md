# Configure your system

The main configuration file to create is in the config folder. There is an example named
[system-example.yml](config/system-example.yml) ready to copy to customise.

There is also a configuration file [defaults.yml](config/defaults.yml).  This file contains all the possible options,
and **is recursively merged with your configuration** on deployment. Therefore, you can override any default value
without having to copy entire branches.

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
- Firewall policies, especially SSH access.
- Security settings
- Backup configuration details

The most important settings are the first two sections, the others can be left to their default values.

Once you have modified the file, you can run the main installer:

## Start the installation

```sh
ansible-playbook -i ../config/hosts.yml playbooks/main.yml
```

# Details of the sections

## Network configuration

Every network subdomain entries, email addresses, etc... will include the domain name:

```yaml

###############################################################################
# Domain and hostname information
network:
  domain: homebox.space
  hostname: mail.homebox.space
  external_ip: auto
  backup_ip: ~
```

The hostname is important, use the real one. If you used the preseed configuration,
it should be just mail and your network domain.

The external IP address is normally automatically detected. If this is not the case, you can specify it manually:

```yaml
network:
  domain: homebox.space
  hostname: mail.homebox.space
  external_ip: 12.34.56.78
  backup_ip: 2001:15f0:5502:bf1:5400:01ff:feca:dea6
```

If your server has a second IP address, you can specify it here as well. By default, none is defined. You can mix IPv4
and IPv6 addresses. DNS entries will be added accordingly.

## User list

The other piece of information you need to fill first is the user list. In its simplest form, you will have something
like this:

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

You can also add more advanced features, like:

- [importing accounts from other mail servers](external-accounts.md).
- [Define some users as administrators](security-configuration.md#defining-administrators)
- [Grant remote access to certain users](security-configuration.md#grant-some-users-remote-access)

## Email options

This is the second most important settings. Here an example of the email options you can override:

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

All options are detailed on the [email configuration](email-configuration.md) page.

## Firewall configuration

The firewall is configured by default to deny everything except what is permitted, both in input and output. The backend
used is "ufw", aka _uncomplicated firewall_. If you have specific requirements, you can define the initial rules
yourself. See the [firewall configuration](firewall-configuration) page for details.

By default, a firewall rule is automatically added to allow SSH connections from the IP address used for the
installation, to avoid being locked out of your system. You can remove this rule at the end of the playbook, especially
if you are [using fwknop](http://localhost:8000/spa-fwknop/) to open your firewall port.

## Security options

Security options are detailed on the [security page](security-configuration.md).
The default settings are

- Automatically install security updates using unattended upgrades.
- Send alerts to the postmaster.
- Force root SSH login to use public key cryptography, and not a password.
- Disable the root password.

Other options are possible, see the security page for details.

## Webmail

By default, the installation script installs Roundcube, but you can disable it if you want. For instance, SOGo is
available as well, with calendars and address books.

```yaml
###############################################################################
# Install a webmail, or not...
webmail:
  install: true
  type: roundcube
```

More details on the [webmail roundcube](webmail-roundcube.md) page.

## Backup configuration

It is possible to regularly backup your emails, for instance locally on a NAS drive, or on internet, using various
methods.

By default, the whole home partition is back up, but you can add or exclude more folders. The detailed instructions are
on the [backup documentation](backup-home.md) page.

## Extra certificates

It is possible to generate more SSL certificates, for instance if you want to deploy other services and want
the certificates to be generated and renewed automatically.

You only have to add one variable `extra-certs` in your configuration file, for instance:

```yaml
# Additional certificates to generate
extra_certs:
  - type: gitlab
    redirect: true
  - type: packages
    redirect: true
```

By adding this, certificates will be automatically generated for the sub domains "gitlab" and "packages", using
letsencrypt.
