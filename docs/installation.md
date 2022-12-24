# Installation steps

## Step 1: Locate your system

Whatever you chose to host your system at home, or with a VPS, you need to specify its location to Ansible.

```sh
cd install/config
cp hosts-example.yml hosts.yml
vi hosts.yml
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
- SOGo settings if you want to install it.
- Firewall policies, especially SSH access.
- Security settings.
- Backup strategies.

The most important settings are the first two sections, the others can be left to their default values.

Once you have modified the file, you are ready to start the installation.

!!! Tip
    The system.yml file is merged with the default configuration on deployment. Therefore, you can override any default
    value without having to copy entire branches.

!!! Warning
    You need to be careful with the indentation in your Yaml file, the number of spaces is significant.

## Step 3: Configure your system

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

### Users list

The file format should be self-explanatory. The other piece of information you need to fill first is the user list. In
its simplest form, you will have something like this:

``` yaml
users:
- uid: john
  cn: John Doe
  first_name: John
  last_name: Doe
  mail: john.doe@example.com
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

You do not have to set the passwords for each user. A random password will be generated, using XKCD, and saved into
_pass_, in the ldap sub directory.


### Email options

This is the second most important settings. Here is an example of the email options you can override:

``` yaml
mail:
  max_attachment_size: 25   # In megabytes
  autoconfig: true          # Support Thunderbird automatic configuration
  autodiscover: false       # Support MS Outlook automatic configuration (uses https)
  quota:
    default: 1G             # Maximum allowed mailbox size for your users.
```

Advanced options are detailed on the [email configuration](email-configuration.md) page.


### Security options

Security options are detailed on the [security page](security-configuration.md).
The default settings are:

- Automatically install security updates using unattended upgrades.
- Send alerts to the postmaster.
- Force root SSH login to use public key cryptography, and not a password.
- Disable the root password.

Other options are possible, see the security page for details.

## Step 4: Start the installation

You can choose a flavour to install, using a different playbook. Four playbooks are included by default: mini, small,
medium and large. Depending on the features and the capacity of your server.

For instance, the mini server:

```sh
cd install
ansible-playbook -i ../config/hosts.yml install-mini.yml
```

!!! Note
    The large version, including clamAV, requires at least 2GB of ram.
