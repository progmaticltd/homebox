# Installation steps


## Step 1: Locate your system

Whatever you chose to host your system at home, or with a VPS, you need to specify its location to Ansible, using an
inventory file. Copy the example file to create your own:

```sh
cd config
cp hosts-example.yml hosts.yml
vi hosts.yml
```

Then, edit the file, and fill your system's IP address, here is an example on your LAN:

```yml
all:
  hosts:
    homebox:
      ansible_host: 192.168.1.254
      ansible_user: root
      ansible_port: 22
      ansible_python_interpreter: /usr/bin/python3
```

!!! Note
    Using root during the installation process is not an absolute requirement, and will depends on your
    configuration. For instance, some VPS will use a specific _admin_ user and `sudo` for administration. Of course,
    once installed, the system can be configured to use the `sudo` command instead.
    See the security section, [Defining administrators](/security-configuration/#defining-administrators).

## Step 2: Describe your system

The main configuration file to create is in the config folder. The `config/defaults` folder contains many versions ready
to copy and customise. There are also pre-configured settings:

- Mini: mail server with only minimal settings, useful for systems with limited resources.
- Small: mail server only with extended options.
- Medium: mail and collaboration server.
- Large: mail, collaboration server and extra components.

More details about the features included in each version can be seen in the [features page](features.md).


```sh
cd config
cp defaults/<version>-small.yml system.yml
nano system.yml
```

Individual components can still be added, by copying the settings from large. For instance to add a small web site to
your settings, copied from _mini_ or _small_, just copy the section from large:

```yml
website:
  install: true
  locale: en_GB.UTF-8
```

Once you have modified the file, you are ready to start the installation.

!!! Tip
    The system.yml file is merged with the default configuration on deployment. Therefore, you can override any default
    value without having to copy entire branches.

!!! Warning
    You need to be careful with the indentation in your Yaml file, the number of spaces is significant. You can use an
    editor that highlight syntax errors.


## Step 3: Configure your system

### Domain name and host name

Every network subdomain entries, email addresses, etc... will include the domain name, so this is important you put the
real value here:

```yml
network:
  domain: homebox.space
  hostname: mail.homebox.space
  external_ip: ~
  backup_ip: ~
```

The hostname is important, so make sure to use the real one. The hostname of your server can be obtained from the
command line, using the `hostname` command.

### External IP addresses

It is important here to specify the external IP address your system can be reached at. Multiple configurations are
supported, for instance, with one IPv4 and one IPv6:

```yml
network:
  domain: homebox.space
  hostname: tartan.homebox.space
  external_ip: 12.34.56.78
  backup_ip: 2001:15f0:5502:bf1:5400:01ff:feca:dea6
```

!!! Tip
    If you do not have a backup IP address, use "~", which means "None" or Null in yaml.


### Create the users list

The file format should be self-explanatory. The other piece of information you need to fill first is the user list. In
its simplest form, you will have something like this:

```yml
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

A random password will be generated for each user, using [XKCD passwords](https://xkcd.com/936/), and saved into your
[credentials store](credentials.md), in the ldap subdirectory.


### Email options

Optionally, you can override the email settings, for instance by activating _autodiscover_ (for Microsoft Outlook), or
changing the quota sizes, like the example below:

```yml
mail:
  max_attachment_size: 50   # In megabytes
  autoconfig: true          # Support Thunderbird automatic configuration
  autodiscover: true        # Support MS Outlook automatic configuration (uses https)
  quota:
    default: 1G               # Maximum allowed mailbox size for your users.
    archive: 10G              # Maximum allowed archived mailbox size for your users.
```

Advanced options are detailed on the [email configuration](email-configuration.md) page.


### Publish DNS information

Although HomeBox has a DNS server included, it is still needed to register information online. The following need to be
registered:

- The [glue record](https://en.wikipedia.org/wiki/Domain_Name_System#Circular_dependencies_and_glue_records) for your
  domains, i.e. the IP addresses and the hostname of your server.
- The keys used to sign your domain records, for DNSSEC.


#### Using Gandi

If you are using [Gandi](https://www.gandi.net/) DNS provider, HomeBox automatically publish the information above,
using Gandi’s API. The only information you need to fill is your Gandi API key, in your password store.

[Create an API key](https://docs.gandi.net/en/account_management/security/developer_access.html#generate-an-api-key)
with Gandi.

The information is looked at this path:

```
backup/<domain>/gandi/api-key
```

For instance, for the domain `example.net`, the API key need to be stored into pass or the credential store of your
choice, using the following path: `backup/example.net/gandi/api-key`.


## Step 4: Start the installation

You can choose a version to install, using a different playbook. Four playbooks are included by default: mini, small,
medium and large. Depending on the features and the capacity of your server.

For instance, the _mini server_ variant:

```sh
cd playbooks
ansible-playbook -e version=mini install-version.yml
```

Depending the version you chose, the installation takes between 10 and 25 minutes, with a reasonable fast laptop and
internet connection.

If something isn't working, open a discussion on [HomeBox website](https://github.com/progmaticltd/homebox/discussions),
and we will be here to help.
