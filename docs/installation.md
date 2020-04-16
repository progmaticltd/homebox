# Installation steps

## Step 1: Locate your system

Whatever you chose to host your system at home, or with a VPS, you need to specify its location to Ansible.

```sh
cd install/config
cp hosts-example.yml hosts.yml
nano hosts.yml
```

Here is an example on your LAN:

``` yaml hl_lines="4"
all:
  hosts:
    homebox:
      ansible_host: 192.168.1.254
      ansible_user: root
      ansible_port: 22
```

Using root during the installation process is a requirement. However, the system can be configured to use sudo once
installed. See the security section, [Defining administrators](/security-configuration/#defining-administrators).

## Step 2: Describe your system

The main configuration file to create is in the config folder. There is an example named system-example.yml ready to
copy and customise. There is also a configuration file defaults.yml. This file contains all the possible options.

```sh
cd config
cp system-example.yml system.yml
nano system.yml
```

The system configuration file is a complete YAML configuration file containing all your settings:

- Network information, specifically your IP address(es) and domain name.
- User and group details, like email addresses and aliases.
- Email parameters, like maximum attachment size, antivirus options, etc.
- Some password policies, like minimum length and complexity.
- Webmail settings (roundcube or SOGo).
- Low level system settings, mainly used during the development phase.
- Firewall policies, especially SSH access.
- Security settings.
- Backup strategies.

The most important settings are the first two sections, the others can be left to their default values.

Once you have modified the file, you are ready to start the installation.

!!! Tip
    The system.yml file is merged with the default configuration on deployment. Therefore, you can override any default
    value without having to copy entire branches.

!!! Warning
    Be careful with the indentation in your Yaml file, the number of spaces is significant.

## Step 3: Start the installation

```sh
cd install
ansible-playbook -i ../config/hosts.yml playbooks/main.yml
```

# Most important sections

## Network configuration

### Domain name and host name

Every network subdomain entries, email addresses, etc... will include the domain name, so this is important you put the
real value here:

```yaml
network:
  domain: homebox.space
  hostname: mail.homebox.space
  external_ip: ~
  backup_ip: ~
```

The hostname is important, use the real one. If you used the preseed configuration, it should be just mail and your
network domain.

### External IP addresses

It is important here to specify the external IP address(es) your system can be reached at.

Multiple configurations are supported, for instance, with one IPv4 and one IPv6:


```yaml
network:
  domain: homebox.space
  hostname: mail.homebox.space
  external_ip: 12.34.56.78
  backup_ip: 2001:15f0:5502:bf1:5400:01ff:feca:dea6
```

!!! Tip
    If you do not have a backup IP address, use "~", which means "None" or Null in yaml.

## Users list

The file format should be self explanatory. The other piece of information you need to fill first is the user list. In
its simplest form, you will have something like this:

``` yaml
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
  aliases:
    - jane@homebox.space
```

The email aliases are the other email addresses that belong to the same user.

You can also add more advanced features, like:

- [Import emails from other accounts](external-accounts.md).
- [Define some users as administrators](security-configuration.md#defining-administrators)
- [Grant remote access to certain users](security-configuration.md#grant-some-users-remote-access)

!!! Note
    You do not have to set the passwords for each user if you don't want to. In this case, a random password will be
    generated, and saved in the deployment backup directory, in the ldap folder. In this case, there will be one file
    called 'jane.pwd'. Otherwise, you can specify the password in clear text. For complex passwords, use quotes

## Email options

This is the second most important settings. Here is an example of the email options you can override:

``` yaml
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
used is "ufw". If you have specific requirements, you can define the initial rules yourself.
See the [firewall configuration](/firewall-configuration/) page for details.

By default, a firewall rule is automatically added to allow SSH connections from the IP address used for the
installation. This should prevent being locked out of your system. You can remove this rule at the end of the playbook,
especially if you are [using fwknop](/firewall-configuration/#single-packet-authorization) to access your system.

## Security options

Security options are detailed on the [security page](security-configuration.md).
The default settings are:

- Automatically install security updates using unattended upgrades.
- Send alerts to the postmaster.
- Force root SSH login to use public key cryptography, and not a password.
- Disable the root password.

Other options are possible, see the security page for details.

## Webmail

By default, the installation script installs Roundcube, but you can disable it if you want. For instance, SOGo is
available as well, with calendars and address books.

```yaml
webmail:
  install: true
  type: roundcube
```

More details on the [webmail roundcube](webmail-roundcube.md) page.

## Backup configuration

It is possible to regularly backup your emails, for instance locally on a NAS drive, or on the internet, using various
methods.

By default, the whole home partition is backed up, but you can add or exclude more folders. The detailed instructions
are on the [backup documentation](/backup-home/) page.

## DNS server configuration

The recommended way is to use the internal DNS server, with a minimal configuration like this:

```yaml
bind:
  install: true
  forward:
    - 8.8.8.8
    - 8.8.4.4
    - 2001:4860:4860::8888
    - 2001:4860:4860::8844
```

You can also use [OpenDNS servers](https://en.wikipedia.org/wiki/OpenDNS#Name_server_IP_addresses) for forward.

Once your DNS set up is complete, you can monitor the [world wide propagation](/dns-propagation/).

## Extra certificates

It is possible to generate more SSL certificates, for instance if you want to deploy other services and want
the certificates to be generated and renewed automatically.

You only have to add one variable `extra-certs` in your configuration file, for instance:

```yaml
extra_certs:
  - type: gitlab
    redirect: true
  - type: packages
    redirect: true
```

By adding these lines, certificates will be automatically generated for the sub domains "gitlab" and "packages", using
letsencrypt.

!!! Tip
    The flag "redirect" means the users will be automatically redirect from http to https when entering the address.
