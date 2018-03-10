
A set of Ansible scripts to setup your personal mail server (and more) for your home...

## Introduction
This project has been created for those who simply want to host their emails - and more - at home,
and don't want to manage the full installation process manually, from scratch.

It is a set of Ansible scripts, to install a fully compliant mail server on Debian Stretch.

It is made to be unobtrusive, standard compliant, secure, robust, extensible and automatic

- Unobtrusive: Most of the packages are coming from the official Debian repository. The final result is what you could have installed manually.
- Standard compliant: The system generates and publish automaticall your DKIM, SPF and DMARC records. It is actually using the excellent [Gandi](https://gandi.net) DNS provider!
- Secure: We are focusing on security, and take packages from official and maintained repositories. No *git clone* or manual download here, everything should be done with apt.
- Robust: the DNS records update script is very safe. You can run it in test mode, with the new zone version created, but not activated, with automatic rollback.
- Extensible: By using LDAP for user authentications, you can use other software, like nextcloud, gitlab or even an OpenVPN server, with one central authentication system.
- Automatic: Most tasks are automated. Even the external IP address detection and DNS update process. In theory, you could use this with a dynamic IP address.

## Current status

| Current feature, implemented and planned                                                                                | Status      |
| ----------------------------------------------------------------------------------------------------------------        | ----------- |
| LDAP users database, SSL & TLS certificates, password policies, optional integration with PAM                           | Done        |
| SSL Certificates creation using letsencrypt, backup and publication on Gandi                                            | Done        |
| DKIM keys generation and backup, publication on Gandi                                                                   | Done        |
| SPF records generation and publication on Gandi                                                                         | Done        |
| DMARC record generation and publication on Gandi, *the reports generation is planned for a future version*              | Done        |
| Generation and publication of automatic Thunderbird configuration (MS Outlook planned)                                  | Done        |
| Postfix configuration and installation, with LDAP lookups, SSL & TLS                                                    | Done        |
| Powerful but light antispam system with [rspamd](https://rspamd.com/)                                                   | Done        |
| Dovecot configuration, IMAPS, Quotas, ManageSieve, Spam and ham autolearn, Sieve auto answers                           | Done        |
| Roundcube webmail, https, sieve filters access, password change, automatic identity creation                            | Done        |
| AppArmor securisation for nginx, dovecot, postfix, etc                                                                  | In progress |
| Automatic migration from old mail server                                                                                | Planned     |
| Automatic encrypted off-site backup                                                                                     | Planned     |
| Web proxy with privacy and parent filtering features                                                                    | Planned     |
| Jabber server using ejabberd and LDAP authentication                                                                    | Planned     |

## Folders:
- config: Ansible configuration files for your platform.
- preseed: Ansible scripts to create an automatic ISO image installer for testing or live system.
- install: Ansible scripts to install the whole server environment.
- backup: Automatic backup of important information upon deployment, (see the [readme](./backup/)).
- sandbox: Put anything you don't want to commit here.

## Mail server installation

First, check that you can login to your server, using SSH on the root account:

`ssh root@mail.example.com`

Replace mail.example.com with the address of your mail server.
This will also add the server to your known_hosts file

### Create your custom configuration

The system configuration file is a complete YAML configuration file containing all your settings:

  - Network information
  - Users and groups
  - Email quotas
  - Webmail settings (roundcube)
  - Password policies
  - Low level system settings
  - DNS update credentials (Gandi API key)
  - Firewall settings
  - Security settings

The most important settings are the first three one, the others can be left to their default values, except during the development phase.

```
  cd config
  cp system-example.yml system.yml
```

This file contains all the network and accounts configuration

### Run the Ansible scripts to setup your email server
The installation folder is using Ansible to setup the mail server
For instance, inside the install folder, run the following command:

`ansible-playbook -vv -i ../config/hosts.yml playbooks/main.yml`

The script will do the following:

- Prepare the system
- Create the accounts
- Add antispam filtering via rspamd
- Install and configure opendmarc
- Install and configure postfix
- Generate the records on Gandi DNS
- Install and configure dovecot
- Install a basic webmail (roundcube)
- Configure security, especially AppArmor

## What do you need in production

### Basic requirements

- A low consumption hardware box to plug on your router, I personally use [pondesk](https://www.pondesk.com/) boxes.
- A computer to run the Ansible scripts.
- A static IP address from your ISP (it is not mandatory, but will work better)
- Some basic newtork knowledge

For automatic DNS records creation and update:
- A registered domain name, with [Gandi](https://gandi.net/)

### Automatic update of the DNS entries

A custom script automatically register domains entries to Gandi, if you provide an API key.
This is useful so you do not have to manage the entries yourself, or if even if you don't have a static IP address.

Here what to do to obtain an API key:

1. Visit the [API key page on Gandi](https://www.gandi.net/admin/api_key)
2. Activate of the API on the test platform.
3. Activate of the production API

Your API key will be activated on the test platform.

__Notes:__

- The initial creation of DNS records for certificate generation should take some time.
- DNS automatic update is actually limited to Gandi, but it should be easy to add more.
- Once the script has been run, the backup folder contains your certificates and DKIM public keys. If you are rebuilding your server from scratch, the same certificates and keys will be used.
- This is a work in progress and a project I am maintaining on my spare time. Although I am trying to be very careful, there might be some errors. In this case, just fill a bug report, or take part.
- I am privileging stability over features. The master branch should stay stable for production.
- There are other similar projects on internet and especially github you could check, for instance [Sovereign](https://github.com/sovereign/sovereign) or [yunohost](https://yunohost.org/). Both have plenty of features, and a different approach to self-hosting, though.

__TODO__:

I am planning to test / try / add the following features, in *almost* no particular order:

- Automatic LUKS setup for the ISO image installer.
- Add a caldav / carddav server (Any that works with LDAP authentication)
- Tor, torrent download station, etc...
- Add optional components (e.g. [Gogs](https://gogs.io/), [openvpn](https://openvpn.net/), [Syncthing](https://syncthing.net/), etc)
- Test other mail systems, like Cyrus, Sogo, etc.

Any ideas welcome...
