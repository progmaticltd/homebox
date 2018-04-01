# Testing / Developing

<!-- TOC -->

- [Testing / Developing](#testing--developing)
    - [Test machine](#test-machine)
    - [Preseed](#preseed)
    - [Router configuration](#router-configuration)
        - [Bridging your workstation](#bridging-your-workstation)
        - [DNS Setup](#dns-setup)
        - [Create your hosts file](#create-your-hosts-file)
    - [System configuration](#system-configuration)
    - [Development playbook](#development-playbook)
    - [Installation playbooks](#installation-playbooks)
    - [Automatic backup](#automatic-backup)
    - [Development cleanup](#development-cleanup)
    - [Tests / Diagnostic playbook.](#tests--diagnostic-playbook)
    - [Some tools to consider](#some-tools-to-consider)

<!-- /TOC -->


There are multiple branches, on this project. The master branch is kept for releases.

The current development are done in the [development](https://github.com/progmaticltd/homebox/tree/dev) branch.


You can start to develop using a virtual machine on your workstation,

## Test machine

The environment runs on Debian Stable. You can install it using a minimalistic ISO image,
called [netinst](https://www.debian.org/CD/netinst/).

I suggest you to use a virtual machine to test, especially with smapshots capabilities.
By using snapshots, you can rollback to any stage and run the Ansible scripts again.
On Linux, KVM/libvirt is the best choice, and VirtualBox might be acceptable.

For instance:

`apt-get install libvirt virt-manager`

## Preseed

There is a preseed folder that creates an an ISO image for automatic installation.
It is using Docker, and builds an automatic installer from a YAML configuration file.
More details [preseed.md](preseed.md).

This installer installs Debian only, it does not deploy the platform.

## Router configuration

Unless your IP address changes too often or your port 25 is blocked, you do not need to have a fixed IP address.

However, the more you want to test, the more your router need to be configured:

- TCP/80 (HTTP): Used to query letsencrypt for the certificates.
  Open it at least to obtain the SSL using LetsEncrypt. You can then close the port once you have the certificates.
- TCP/25 : SMTP, to receive and transfer emails from and to other SMTP servers on internet.
  You need this one only to test the reception and transmission of external emails.

Now, all the rest can be done internally, without exposing your test machine.
These ports open don't need to be forwarded by your router during the development time:

- TCP/143 and TCP/993 : IMAP and IMAPS
- TCP/110 and TCP/995 : POP3 and POP3S
- TCP/587 : [Submission](https://en.wikipedia.org/wiki/Opportunistic_TLS).
- TCP/465 : [SMTPS](https://en.wikipedia.org/wiki/SMTPS) (this on is kept for compatibility with some old devices,
  but perhaps will be removed soon)
- TCP/4190 : ManageSieve. Used to remotely access your mail filters, for instance with
  [thunderbird sieve plugin](https://addons.mozilla.org/en-US/thunderbird/addon/sieve/).
- TCP/443 : HTTPS access for the webmail and also Outlook autodiscover feature.

### Bridging your workstation

If you are using a virtual machine, it is better to use a bridge on your workstation,
to transparently forward the traffic from internet.

- On Debian: https://wiki.debian.org/BridgeNetworkConnections
- On Linux arch: [Network bridge](https://wiki.archlinux.org/index.php/Network_bridge)
- A fancy guide on Ubuntu: [Linux bridge with Network Manager](http://ask.xmodulo.com/configure-linux-bridge-network-manager-ubuntu.html)

### DNS Setup

There is a script that actually updates automatically DNS entries, if you are using Gandi.
For development, the simplest is to add a wilcard entry in your DNS, that would point
to your virtual machine.

I will explain this section more in details later.

I am also planning to add more DNS providers, or even to provides a custom DNS server.
The initial creation of DNS records for certificate generation should take some time.
So, it is better to do this before anything else.

### Create your hosts file

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

## System configuration

First, as you would do for a live environment, copy the sample configuration to create your own:

```
cd config
cp system-example.yml system.yml
```

The file is self explanatory, and inside, you will find the following block:

```
system:
  release: stretch
  login: true
  ssl: letsencrypt
  devel: true
  debug: true
```

Setting the debug flag to true will activate a lot of debug options in Dovecot, OpenLDAP, Postfix, etc...
You can then filter in the console, using for instance `journalctl -u postfix -u dovecot*` to view postfix and dovecot logs respectively.

The devel flag is generating minor modification in the system, for instance the milter port numbers being fixed. I'll probably merge the two settings later.

## Development playbook

The first playbook to run is probably "dev-support.yml". It installs some diagnostic and convenience packages
on the server, to make your life easier during the development phase.

For instance, these packages are installed:

- mc
- telnet
- dnsutils
- whois
- tmux
- pfqueue
- aptitude
- man
- less
- vim
- net-tools
- file
- swaks
- curl
- locate
- colorized-logs
- bash-completion

The script also configures a basic bashrc / zshrc.

## Installation playbooks

The main playbook 'main.yml' and includes all other playbooks, with some of them conditional,
as some components are optional.

```
# Complete list of playbooks to run, in this order
- import_playbook: system-prepare.yml
- import_playbook: ldap.yml
- import_playbook: homes.yml

# System protection: antispam
- import_playbook: rspamd.yml

# System protection: antivirus
- import_playbook: clamav.yml
  when: mail.antivirus.active

# Email server: MTA
- import_playbook: opendkim.yml
- import_playbook: opendmarc.yml
- import_playbook: cert-smtp.yml
- import_playbook: postfix.yml

# Create DNS entries (Only Gandi for now)
- import_playbook: dns-update.yml

- import_playbook: cert-pop3.yml
- import_playbook: cert-imap.yml
- import_playbook: dovecot.yml

# Install nginx as the default web server, if needed
- import_playbook: nginx.yml
  when: webmail.install or mail.autodiscover or mail.autoconfig

# Install the selected webmail
- import_playbook: roundcube.yml
  when: webmail.install and webmail.type == 'roundcube'

# Automatic configuration for email clients.
- import_playbook: autodiscover.yml
  when: mail.autodiscover
- import_playbook: autoconfig.yml
  when: mail.autoconfig

# Add the old emails import scripts for each users
- import_playbook: import-accounts.yml
```

## Automatic backup

Once the script has been run, the backup folder contains important files, like certificates, passwords, etc. See (see the [backup.md](./backup.md) for details).

## Development cleanup

This playbook do the opposite of dev-support, by uninstalling the packages used for development,
and restoring the bashrc to its default state.
You probably want to run this script before putting your server in production.

## Tests / Diagnostic playbook.

There is also a test playbook 'tests.yml'. This playbook runs a list of system and integration tests on your server. This is useful for diagnostic purposes, and also during the development phase, to be sure nothing is broken.

It does not replace a full test suite in a pre-production environment, but has been enough so far to spot
the mistakes I have made in my Ansible scripts logic.

The following roles are run:

- Install the development packages above,
- Basic system tests
- LDAP server: Binding, users list, SSL certificate, etc.
- Home folders: Presence and permissions
- Antivirus rspamd: Current state
- Service opendmarc: Current state
- SMTP certificate: presence and validity
- Service opendkim: Current state, key validdity
- Service postfix: Current state, certificate, emails sending and receiving
- POP3 certificate: presence and validity
- IMAP certificate: presence and validity
- Service dovecot: current state, user authentication, email resolution
- Web site for roundcube: basic access, SSL certificate test
- Web site "autoconfig" for Thunderbird: Check the validity of the XML generated
- Web Site "autodiscover" for Outlook: HTTPS certificate, check the validity of the XML generated
- Antivirus tests, for instance check that an email with a virus is bounced.

## Some tools to consider

- The fantastic tmux, mandatory IMHO: [tmux github page](https://github.com/tmux).
- Emacs or vim, but if you are not ready, [VisualStudio code](https://code.visualstudio.com/) 
  is not too bad as well, and is very well integrated in Debian.
- Test your SMTP server compliance: [mxtoolbox.com](http://mxtoolbox.com/).