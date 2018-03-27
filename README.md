
A set of Ansible scripts to setup your personal mail server (and more) for your home...

This project was initially meant to host emails at home, but you can use it on a dedicated or VPS server online.

This project is for you if:

- You are interested to host your emails on your personal mail server, at home or online.
- You want your server to be secure against physical or remote intrusion.
- You don't want to pass your weekends applying security updates or hacking it.
- You trust the Debian community to push security updates in time.

## Current status and supported features
 
| Current feature, implemented and planned                                                                            | Status    | Tested   |
| ------------------------------------------------------------------------------------------------------------------- | :-------: | :------: | 
| LDAP users database, SSL & TLS certificates, password policies, integration with the system and PAM.                | Done      |   Yes    | 
| SSL Certificates generation with [letsencrypt](https://letsencrypt.org), automatic local backup and publication.    | Done      |   Yes    | 
| DKIM keys generation and automatic local backup and publication on Gandi                                            | Done      |   Yes    | 
| SPF records generation and publication on Gandi                                                                     | Done      |   Yes    | 
| DMARC record generation and publication on Gandi, *the reports generation is planned for a future version*          | Done      |   Yes    | 
| Generation and publication of automatic Thunderbird (autoconfig) and Outlook (autodiscover) configuration           | Done      |   Yes    | 
| Postfix configuration and installation, with LDAP lookups, and protocols STARTTLS/Submission/SMTPS                  | Done      |   Yes    | 
| Automatic copy of sent emails into the sent folderm ala GMail                                                       | Done      |   Yes    | 
| Powerful and light antispam system with [rspamd](https://rspamd.com/)                                               | Done      |   No     | 
| Dovecot configuration, IMAPS, POP3S, Quotas, ManageSieve, Spam and ham autolearn, Sieve auto answers                | Done      |  Basic   | 
| Roundcube webmail, https, sieve filters management, password change, automatic identity creation                    | Done      |  Basic   | 
| AppArmor securisation for rspamd, nginx, dovecot, postfix                                                           | Done      |   No     | 
| ISO image builder, for automatic Debian installation and a fully encrypted drive using LUKS ([preseed](preseed/))   | Done      |          | 
| Antivirus for inbound / outbound emails with [clamav](https://www.clamav.net/)                                      | Working on |          | 
| Dovecot full text search in emails and attachments.                                                                 | Planned   |          | 
| Automatic home router configuration using [upnp](https://github.com/flyte/upnpclient).                              | Planned   |          | 
| Web proxy with privacy and parent filtering features                                                                | Planned   |          | 
| Automatic migration from old mail server using imap synchronisation                                                 | Planned   |          | 
| Automatic encrypted off-site backup, probably with [borg-backup](https://www.borgbackup.org/)                       | Planned   |          | 
| Jabber server, probably using [ejabberd](https://www.ejabberd.im/)                                                  | Planned   |          |


## Basic installation

It is using [Ansible](https://en.wikipedia.org/wiki/Ansible_(software)) scripts, to automate tasks you would have done manually, so it 

### Prerequisites

- A workstation to run the Ansible scripts.
- A static IP address from your ISP (it is not mandatory, but will work better).
- A server plugged on your router, or a virtual machine for testing.
- Some basic Linux networking knowledge.

### Folders

The repository contains a few folders you should be familiar with:

- config: Yaml configuration files for your homebox device.
- preseed: Dockerfile to create an automatic ISO image installer for testing and live system.
- install: Ansible scripts to install the whole server environment.
- backup: Automatic backup of important information after deployment, (see the [readme](./backup/)).
- sandbox: Put anything you don't want to commit here.
- doc: Various documentation, work in progress.

### 1. Create your hosts file

```
  cd config
  cp hosts-example.yml hosts.yml
```

The host file is in YAML format, and contains only one host, which is your homebox server.

Here an example:
```
all:
  hosts:
    homebox:
      ansible_host: 192.168.42.1
      ansible_user: root
      ansible_port: 22
```

I have actually tested with the Ansible remote user as root. However, it should be possible to run as an admin user and use sudo with little modifications.

### 2. Create your custom configuration

The main configuration file to create is in the config folder.

There is an example configuration file available in the config folder [system-example.yml](config/system-example.yml).

```
  cd config
  cp system-example.yml system.yml
  ```

The system configuration file is a complete YAML configuration file containing all your settings:

  - Network information
  - Users and groups
  - Some email parameters, like quota and maximum attachment size
  - Some password policies, that are - for now - enforced through the webmail password change interface.
  - Webmail settings (roundcube)
  - Low level system settings, mainly used during the development phase.
  - DNS update credentials (Gandi API key)
  - Firewall policy for SSH
  - Security settings, like AppArmor activation.

The most important settings are the first three sections, the others can be left to their default values, except during the development phase.

This file contains all the network and accounts configuration

### 3. Network configuration

Initially, the following TCP ports are required:

- To obtain your certificates, you need your system to be accessible externally on the port 80.
- To test sending and receiving emails, your system should be accessible on the port 25 as well
- To retrieve emails, your system should be accessible on ports 143, 993, 110, 995
- To send emails, your system should be accessible on ports 587 and/or 465
- For Thunderbird automatic configuration, your system should be accessible on port 80.
- Once installed, the webmail is accessible ni http (port 80), but redirects you directly to https (port 443)

#### Home installation

Hosting your emails at home requires your router to be configured to forward the traffic above to your homebox server.

The easiest way to to create a DMZ in your router. Another approach is to use Upnp to configure your router automatically. This feature will be added in a future version.

#### Hosted installation

If you are hosted using a professional provider, then you probably don't need help on opening the ports and configuring your platform. Just use the reference above

### 4. Automatic DNS records creation and update:

One way to configure your DNS is to use a wildcard entry, that would redirect everything to your homebox. There is also a script that configures your DNS entries automatically. The current version only supports [Gandi](https://gandi.net/).

This custom script needs an API key to run. This is also useful so you do not have to manage the entries yourself, or if even if you don't have a static IP address.

Here what to do to obtain an API key on gandi:

1. Visit the [API key page on Gandi](https://www.gandi.net/admin/api_key)
2. Activate of the API on the test platform.
3. Activate of the production API

You should obtain credentials like this:

- A Gandi "handle", like AR789-GANDI
- An API key of 24 characters, like "TYdiYFPfXR3j3vMfmTc82hVc"


I am planning to add more DNS providers, or even to provides a custom DNS server.
The initial creation of DNS records for certificate generation should take some time. I am thinking to a solution for this.

### 5. Run the Ansible scripts to setup your email server

The installation folder is using Ansible to setup the mail server
For instance, you can run the following commands:

```
cd install
ansible-playbook -vv -i ../config/hosts.yml playbooks/main.yml
```

The script will call the playbooks below:

- system-prepare.yml : Prepare the system, and activate AppArmor if you have set the flag to true.
- ldap.yml : Install OpenLDAP, and configure the user and group accounts.
- homes.yml : Configure user's home folders automatic creation.
- rspamd.yml : Install the rspamd mail filtering.
- opendmarc.yml : Install OpenDMARC for compliance.
- cert-smtp.yml : Create an SMTP certificate for your domain.
- opendkim.yml : Install OpenDKIM, and creates a key (4096 bits) for your domain.
- postfix.yml : Install and configure postfix
- dns-update.yml : Create and publish DNS records.
- cert-pop3.yml : Create an SSL certificate for email retrieval using POP3.
- cert-imap.yml : Create an SSL certificate for email retrieval using IMAP4.
- dovecot.yml : Install and configure dovecot.
- roundcube.yml : Install and configure roundcube webmail.
- autodiscover.yml : Configure Microsoft Outlook autodiscovery feature.
- autoconfig.yml :  Configure Mozilla Thunderbird autoconfig feature.

There is also a few others Ansible scripts worth to mention:

- tests.yml : Run a set of self-diagnostic from inside the box, for each service
- dev-support : Install some convenient tools for better development support on the server
- dev-cleanup : Remove the development packages previously installed
- ldap-refresh: Read again the user's list, and refresh email aliases

During the development phase, you can also run the scripts one by one.

**Note: The scripts are idempotents, you can run then multiple time without error.**

#### Automatic backup

- Once the script has been run, the backup folder contains important files to run your scripts again. See (see the [readme](./backup/))

## Future versions

I am planning to test / try / add the following features, in *almost* no particular order:

- Install [Sogo](https://sogo.nu/) for caldav / carddav server, with of course LDAP authentication.
- Add optional components (e.g. [Gogs](https://gogs.io/), [openvpn](https://openvpn.net/), [Syncthing](https://syncthing.net/), etc).

## Other projects to mention

There are other similar projects on internet and especially github you could check, for instance:

- [Sovereign](https://github.com/sovereign/sovereign): A different target, but a similar deployment approach using Ansible.
- [yunohost](https://yunohost.org/): Contains a lot of plugins and features, not all of them are stable, but it is worth testing.
- [mailinabox](https://mailinabox.email/), more oriented to online hosting, but very good as well.
- [and many...](https://github.com/Kickball/awesome-selfhosted)

All have plenty of modern features, but a different approach to self-hosting, though.
