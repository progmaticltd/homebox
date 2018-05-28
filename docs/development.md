## Branches

- The current developments are done in the
[dev](https://github.com/progmaticltd/homebox/tree/dev) branch.
- The master branch is kept for releases.

## Test machine

You can start to develop using a virtual machine on your workstation, for instance using
KVM or VirtualBox. The environment runs on Debian Stable. You can install it using a
minimalistic ISO image, called [netinst](https://www.debian.org/CD/netinst/).

I suggest you to use a virtual machine to test, especially with snapshots capabilities.
By using snapshots, you can rollback to any stage and run the Ansible scripts again. On
Linux, KVM/libvirt is the best choice, and VirtualBox might be acceptable.

For instance:

`apt-get install libvirt virt-manager`

## Preseed

There is a preseed folder that creates an an ISO image for automatic installation.  It is
using Docker, and builds an automatic installer from a YAML configuration file.
The [preseed page](preseed.md) give more details about this feature.

_Note: This installer installs Debian only, it does not deploy the platform._

## Router configuration

Unless your IP address changes too often or your port 25 is blocked, you do not need to
have a fixed IP address.

However, the more you want to test, the more your router need to be configured:

- TCP/80 (HTTP): Used to query letsencrypt for the certificates. Open it at least to
  obtain the SSL using LetsEncrypt. You can then close the port once you have the
  certificates.
- TCP/25: SMTP, to receive and transfer emails from and to other SMTP servers on
  internet. You need this one only to test the reception and transmission of external
  emails.

Now, all the rest can be done internally, without exposing your test machine. These ports
don't need to be forwarded by your router during the development time:

- TCP/143 and TCP/993 : IMAP and IMAPS
- TCP/110 and TCP/995 : POP3 and POP3S
- TCP/587 : [Submission](https://en.wikipedia.org/wiki/Opportunistic_TLS).
- TCP/465 : [SMTPS](https://en.wikipedia.org/wiki/SMTPS) (this on is kept for
  compatibility with some old devices, but perhaps will be removed soon)
- TCP/4190 : ManageSieve. Used to remotely access your mail filters, for instance with
  [thunderbird sieve plugin](https://addons.mozilla.org/en-US/thunderbird/addon/sieve/).
- TCP/443 : HTTPS access for the webmail and also Outlook autodiscover feature.
- TCP/5222 and TCP/5269 : Jabber, clients to server and server to server implementation.
- UDP/53 and TCP/53 : DNS Server.

### Bridging your workstation

If you are using a virtual machine, it is better to use a bridge on your workstation, to
transparently forward the traffic from internet.

- On Debian: https://wiki.debian.org/BridgeNetworkConnections
- On Linux arch: [Network bridge](https://wiki.archlinux.org/index.php/Network_bridge)
- A fancy guide on Ubuntu:
  [Linux bridge with Network Manager](http://ask.xmodulo.com/configure-linux-bridge-network-manager-ubuntu.html)

### DNS Setup

There is a script that actually updates automatically DNS entries, if you are using Gandi.
For development, the simplest is to add a wilcard entry in your DNS, that would point to
your virtual machine.

The initial creation of DNS records for certificate generation should take some time. So,
it is better to do this before anything else.

Otherwise, you can use the DNS server implemented with Bind.

### Create your hosts file

```sh

  cd config
  cp hosts-example.yml hosts.yml

```

The host file is in YAML format, and contains only one host, which is your homebox server.

Here an example:

```yaml

all:
  hosts:
    homebox:
      ansible_host: 192.168.42.1
      ansible_user: root
      ansible_port: 22

```

I have actually tested with the Ansible remote user as root. However, it should be
possible to run as an admin user and use sudo with little modifications.

## System configuration

First, as you would do for a live environment, copy the sample configuration to create
your own:

```sh

cd config
cp system-example.yml system.yml

```

The file is self explanatory, and inside, you will find the following block:

```yaml

system:
  release: stretch
  login: true
  ssl: letsencrypt
  devel: true
  debug: true

```

Setting the debug flag to true will activate a lot of debug options in Dovecot, OpenLDAP,
Postfix, etc...  You can then filter in the console, using for instance `journalctl -u
postfix -u dovecot*` to view postfix and dovecot logs respectively.

The devel flag is generating minor modification in the system, for instance the milter
port numbers being fixed. I'll probably merge the two settings later.

## Development playbook

The first playbook to run is probably "dev-support.yml". It installs some diagnostic and
convenience packages on the server, to make your life easier during the development phase.

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

The main playbook 'main.yml' and includes all other playbooks, with some of them
conditional, as some components are optional.

## Automatic backup

Once the script has been run, the backup folder contains important files, like
certificates, passwords, etc. See (see the [deployment backup](./deployment-backup.md)
page for details).

## Development cleanup

This playbook do the opposite of dev-support, by uninstalling the packages used for
development, and restoring the bashrc to its default state. You probably want to run this
script before putting your server in production.

## Tests / Diagnostic playbooks.

There is also a tests folder that contains test playbooks.
These playbooks are running a list of system and integration tests on your development server.
This is useful for diagnostic purposes and also during the development phase, to be sure nothing
is broken before committing anything.

It does not replace a full test suite in a pre-production environment, but has been enough
so far to catch common mistakes made in the scripts.

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
- Web Site "autodiscover" for Outlook: HTTPS certificate, check the validity of the XML
  generated
- Antivirus tests, for instance check that an email with a virus is bounced.
- Full text search inside attachments
- DNS records when the DNS server is installed.

## Some development tools to consider

- The fantastic tmux, mandatory IMHO: [tmux github page](https://github.com/tmux).
- Emacs or vim, but if you are not ready, [VisualStudio
  code](https://code.visualstudio.com/) is not too bad as well, and is very well
  integrated in Debian / Ubuntu.
- Test your SMTP server compliance: [mxtoolbox.com](http://mxtoolbox.com/).
- DNSSEC records debugger : https://dnssec-analyzer.verisignlabs.com/
- DNS propagation checker: https://www.whatsmydns.net/
