## External mailing lists

If something goes wrong, here are a few resources:

- The [Postfix mailing lists](http://www.postfix.org/lists.html).
- The [Dovecot mailing lists](https://www.dovecot.org/mailinglists.html).
- The [Debian mailing lists](https://lists.debian.org/).
- Our [github page](https://github.com/progmaticltd/homebox)
- Finally, [Duckduckgo](https://duckduckgo.com/) or [Google](https://google.com/).

## Folders content

The repository contains a few folders you should be familiar with:

- config: The main Yaml configuration files for your homebox device.
- preseed: Docker environment to create an automatic ISO image installer for Debian.
- install: Ansible scripts to install or test the whole server environment.
- backup: A very useful folder that contains some important files like the passwords and certificates generated when
  deploying the system. This allows you to "replay" the deployment on a new server after a disaster, without losing any
  information. This folder is generated automatically on the first deployment, and ignored by git.
- tests: Ansible playbooks to test the platform.
- sandbox: Put here anything you don't want to commit.
- docs: This project documentation.
- uninstall: Ansible scripts to uninstall some of the components. This allows you to test them.
- devel: A set of containers to help setup a local development environment.

## Branches

- The current developments are done in the [dev](https://github.com/progmaticltd/homebox/tree/dev) branch.
- The master branch is kept for releases.

Starting in May 2019, the approach will be to use gitflow, from the dev branch.

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

!!! Note
    This installer installs Debian only, it does not deploy the platform.

## Router configuration

Unless your IP address changes too often or your port 25 is blocked, you do not need to
have a fixed IP address.

However, the more you want to test, the more your router need to be configured:

- TCP/80 (HTTP): Used to query letsencrypt for the certificates. Open it at least to
  obtain the SSL using LetsEncrypt. You can then close the port once you have the
  certificates.
- TCP/25: SMTP, to receive and transfer emails from and to other SMTP servers on the
  internet. You need this one only to test the reception and transmission of external
  emails.

Now, all the rest can be done internally, without exposing your test machine. These ports
don't need to be forwarded by your router during the development time:

- TCP/143 and TCP/993: IMAP and IMAPS
- TCP/110 and TCP/995: POP3 and POP3S
- TCP/587: [Submission](https://en.wikipedia.org/wiki/Opportunistic_TLS).
- TCP/465: [SMTPS](https://en.wikipedia.org/wiki/SMTPS) (this one is kept for
  compatibility with some old devices, but perhaps will be removed soon)
- TCP/4190: ManageSieve. Used to remotely access your mail filters, for instance with
  [thunderbird sieve plugin](https://addons.mozilla.org/en-US/thunderbird/addon/sieve/).
- TCP/443: HTTPS access for the webmail and also Outlook autodiscover feature.
- TCP/5222 and TCP/5269: Jabber, clients to server and server to server implementation.
- UDP/53 and TCP/53: DNS Server.

### Bridging your workstation

If you are using a virtual machine, it is better to use a bridge on your workstation, to
transparently forward the traffic from the internet.

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

Here is an example:

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
  devel: true
  debug: true

```

### The "debug" flag

Setting the debug flag to true will activate a lot of debug options in Dovecot, OpenLDAP, Postfix, etc...  You can then
filter in the console, using for instance `journalctl -u postfix -u dovecot*` to view postfix and dovecot logs
respectively.

### The "devel" flag

When you set this flag to true, various settings are changed in the development.

By default:

- The certificates deployed are staging certificates only, which allows you to request more to LetsEncrypt.
- The certificates are backed up on your local machine, allowing you to redeploy without asking again the same
  certificates, which is also faster.
- If you want to test your system from a local computer, you will need to add the staging version of the root
  certificate authority. It can be downloaded on the on the [LetsEncrypt staging environment
  page](https://letsencrypt.org/docs/staging-environment/).


As an option, without Letsencrypt:

- The certificates can be deployed from a local ACME server using [Pebble](https://github.com/letsencrypt/pebble).
- The expected server is provided as a container by a `docker-compose` file in the `devel` directory.
- The server is for testing only and has some usage constraints which are further described in the next section.

### The devel environment

To be able to develop and test locally, the `devel` directory provides a
`docker-compose` file with definitions for the following containers:

- A `pebble` server to act as a testing ACME server to replace Letsencrypt.
- A `challtestsrv` to act as a manageable DNS server for the ACME server.
- An `apt-cacher` server.

```sh
$ cd devel/
$ docker-compose up
Starting devel_pebble_1         ... done
Recreating devel_challtestsrv_1 ... done
Starting devel_apt-cacher_1     ... done
Attaching to devel_apt-cacher_1, devel_pebble_1, devel_challtestsrv_1
[…]
```

These containers are connected to a bridge and addressed in the subnet
10.30.50.0/24. The playbooks assume the predefined static IP addresses for the
pebble and the apt-cacher servers. The server's `external_ip` will be used to
resolve any DNS request made by the pebble server.

The use of the pebble server in the playbooks is configured with:

```yaml
system:
[…]
  devel: true
[…]

devel:
  acme_server: pebble
```

The Pebble ACME server is designed to create temporary CAs and certificates
that can only be used for testing. A new temporary CA is created every time the
server is started, and it is destroyed when it stops. The `certificates` role
in the playbooks will install the current CA whenever they are run.

Everytime the Pebble server is started, to have a coherent system, the
certificates might need to be generated again. It can be done by running the
playbooks or with the help of the `certificates` tag:

```sh
$ cd install/
$ ansible-playbook -i ../config/hosts.yml playbooks/main.yml -t certificates
```

When developing or testing locally, most probably with a local domain name like
`example.local`, there is no need for the DNS propagation checks during
installation and testing:

```yaml
bind:
[…]
  propagation:
    check: false
[…]
```

It also disables one of the opendmarc test which requires an external validating resolver.

The `apt-cacher` server can be used to speed up package updates on reinstalls by configuring:

```yaml
system:
[…]
  apt_cacher: 10.30.50.4
```

Finally, to allow the use of these service the firewall should be configured with:

```yaml
firewall:
  output:
    policy: deny
    rules:
      - dest: any
        port: 80,443
        comment: 'Allow web access'
      - dest: any
        proto: udp
        port: 53
        comment: 'Allow DNS requests'
      - dest: any
        proto: udp
        port: 123
        comment: 'Allow NTP requests'
      - dest: any
        proto: udp
        from_port: 68
        port: 67
        comment: 'Allow DHCP requests'
      - dest: any
        port: 25
        comment: 'Allow SMTP connections to other servers'
      - dest: any
        port: 110,995,143,993
        comment: 'Allow the retrieval of emails from other servers (POP/IMAP)'
      - dest: 10.30.50.2
        port: 14000,15000
        comment: 'Allow access to the Pebble ACME server'
      - dest: 10.30.50.3
        port: 8055
        comment: 'Allow access to the Pebble challenge Test server'
      - dest: 10.30.50.4
        port: 3142
        comment: 'Allow APT cacher access'
```

### Setting up ansible-lint before commit

The program ansible-lint is executed by the continuous integration platform, and should be used for each commit. A hook
is provided in the git-hooks folder.

The ansible-lint software needs to be installed on your machine. We are using the version in Debian Buster. The
ansible-lint configuration file is in `config/ansible-lint-default.yml`.

To ensure the hook is executed before each commit, run this on your local machine:

```sh
git config --local core.hooksPath git-hooks
```

## Development playbook

The first playbook to run is probably "dev-support.yml". It installs some diagnostic and convenience packages on the
server, to make your life easier during the development phase.

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

- The script also configures a basic bashrc / zshrc.
- It is also adding the LetsEncrypt staging root certificate authority to the system.

## Installation playbooks

The main playbook 'main.yml' and includes all other playbooks, with some of them conditional, as some components are
optional.

## Automatic backup

Once the script has been run, the backup folder contains important files, like certificates, passwords, etc. See (see
the [deployment backup](./deployment-backup.md) page for details).

## Development cleanup

This playbook do the opposite of dev-support, by uninstalling the packages used for development, and restoring the
bashrc to its default state. You probably want to run this script before putting your server in production.

It is also removing the LetsEncrypt staging root certificate authority from the system.

## Tests / Diagnostic playbooks.

There is also a tests folder that contains test playbooks.  These playbooks are running a list of system and integration
tests on your development server.  This is useful for diagnostic purposes and also during the development phase, to be
sure nothing is broken before committing anything.

It does not replace a full test suite in a pre-production environment, but has been enough so far to catch common
mistakes made in the scripts.

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

## Profiling the playbook

You can profile the time taken by the whole playbook, using the Ansible profile_roles plugin:

```ini hl_lines="5"
[defaults]
retry_files_enabled = False
display_skipped_hosts = False
stdout_callback = yaml
callback_whitelist = profile_roles
roles_path = .:{{ playbook_dir }}/../../common/roles/
connection_plugins = {{ playbook_dir }}/../../common/connection-plugins/
remote_tmp = /tmp/
```

Then, once you have finished to run the playbook, you will see the total time. For instance:

For a full deployment:

```
PLAY RECAP *********************************************************************
homebox                    : ok=644  changed=394  unreachable=0    failed=0
localhost                  : ok=0    changed=0    unreachable=0    failed=0

Saturday 22 June 2019  15:18:09 +0100 (0:00:00.424)       0:18:59.596 *********
===============================================================================
dovecot --------------------------------------------------------------- 176.27s
system-prepare -------------------------------------------------------- 118.33s
postfix --------------------------------------------------------------- 112.06s
certificates ---------------------------------------------------------- 100.98s
load-defaults ---------------------------------------------------------- 81.55s
roundcube -------------------------------------------------------------- 67.77s
ldap ------------------------------------------------------------------- 66.80s
clamav ----------------------------------------------------------------- 59.39s
external-ip ------------------------------------------------------------ 39.54s
sogo ------------------------------------------------------------------- 38.57s
opendkim --------------------------------------------------------------- 27.84s
dns-server-bind -------------------------------------------------------- 27.40s
setup ------------------------------------------------------------------ 25.43s
rspamd ----------------------------------------------------------------- 24.34s
opendmarc -------------------------------------------------------------- 23.52s
packages --------------------------------------------------------------- 21.38s
website-simple --------------------------------------------------------- 17.81s
system-cleanup --------------------------------------------------------- 16.34s
user-setup ------------------------------------------------------------- 15.64s
autoconfig ------------------------------------------------------------- 14.98s
autodiscover ----------------------------------------------------------- 14.98s
remote-access ---------------------------------------------------------- 14.89s
nginx ------------------------------------------------------------------ 13.14s
imapproxy --------------------------------------------------------------- 8.58s
dns-server-bind-refresh ------------------------------------------------- 2.69s
well-known-services ----------------------------------------------------- 2.10s
dns-server-check-propagation -------------------------------------------- 1.22s
ejabberd ---------------------------------------------------------------- 0.75s
transmission ------------------------------------------------------------ 0.63s
borg-backup ------------------------------------------------------------- 0.58s
zabbix-server ----------------------------------------------------------- 0.54s
luks-remote ------------------------------------------------------------- 0.50s
fwknop-server ----------------------------------------------------------- 0.40s
privoxy ----------------------------------------------------------------- 0.31s
backup-server ----------------------------------------------------------- 0.19s
tor --------------------------------------------------------------------- 0.18s
import-accounts --------------------------------------------------------- 0.18s
rspamd-web -------------------------------------------------------------- 0.18s
fwknop-client ----------------------------------------------------------- 0.17s
ssh-keygen -------------------------------------------------------------- 0.13s
php-fpm ----------------------------------------------------------------- 0.08s
extra-certs ------------------------------------------------------------- 0.06s
sendxmpp ---------------------------------------------------------------- 0.05s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
total ---------------------------------------------------------------- 1139.50s
```

And for an update:

```text
PLAY RECAP *********************************************************************
homebox                    : ok=557  changed=66   unreachable=0    failed=0
localhost                  : ok=0    changed=0    unreachable=0    failed=0

Saturday 22 June 2019  14:50:39 +0100 (0:00:00.442)       0:09:57.571 *********
===============================================================================
load-defaults ---------------------------------------------------------- 85.87s
certificates ----------------------------------------------------------- 78.07s
dovecot ---------------------------------------------------------------- 54.67s
postfix ---------------------------------------------------------------- 42.22s
external-ip ------------------------------------------------------------ 36.11s
ldap ------------------------------------------------------------------- 34.02s
system-prepare --------------------------------------------------------- 27.48s
setup ------------------------------------------------------------------ 23.86s
dns-server-bind -------------------------------------------------------- 22.62s
opendkim --------------------------------------------------------------- 22.37s
rspamd ----------------------------------------------------------------- 22.30s
opendmarc -------------------------------------------------------------- 18.06s
roundcube -------------------------------------------------------------- 17.91s
user-setup ------------------------------------------------------------- 15.80s
nginx ------------------------------------------------------------------ 15.27s
sogo ------------------------------------------------------------------- 14.75s
remote-access ---------------------------------------------------------- 13.83s
website-simple ---------------------------------------------------------- 8.27s
system-cleanup ---------------------------------------------------------- 7.65s
clamav ------------------------------------------------------------------ 6.65s
autoconfig -------------------------------------------------------------- 5.68s
autodiscover ------------------------------------------------------------ 5.37s
imapproxy --------------------------------------------------------------- 4.82s
packages ---------------------------------------------------------------- 3.09s
dns-server-bind-refresh ------------------------------------------------- 1.93s
well-known-services ----------------------------------------------------- 1.35s
dns-server-check-propagation -------------------------------------------- 0.98s
ejabberd ---------------------------------------------------------------- 0.77s
transmission ------------------------------------------------------------ 0.75s
borg-backup ------------------------------------------------------------- 0.62s
zabbix-server ----------------------------------------------------------- 0.58s
luks-remote ------------------------------------------------------------- 0.53s
fwknop-server ----------------------------------------------------------- 0.43s
privoxy ----------------------------------------------------------------- 0.32s
access-check ------------------------------------------------------------ 0.28s
rspamd-web -------------------------------------------------------------- 0.24s
backup-server ----------------------------------------------------------- 0.21s
tor --------------------------------------------------------------------- 0.20s
fwknop-client ----------------------------------------------------------- 0.18s
access-report ----------------------------------------------------------- 0.16s
ssh-keygen -------------------------------------------------------------- 0.14s
php-fpm ----------------------------------------------------------------- 0.09s
extra-certs ------------------------------------------------------------- 0.06s
sendxmpp ---------------------------------------------------------------- 0.06s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
total ----------------------------------------------------------------- 597.48s
```

## Some development tools to consider

- The fantastic tmux, mandatory IMHO: [tmux github page](https://github.com/tmux).
- Emacs or vim, but if you are not ready, [VisualStudio code](https://code.visualstudio.com/) is not too bad as well,
  and is very well integrated in Debian / Ubuntu.
- Test your SMTP server compliance: [mxtoolbox.com](http://mxtoolbox.com/).
- DNSSEC records debugger: https://dnssec-analyzer.verisignlabs.com/
- DNS propagation checker: https://www.whatsmydns.net/
