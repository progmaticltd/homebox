## External mailing lists

If something goes wrong, here are a few resources:

- The [Postfix mailing lists](http://www.postfix.org/lists.html).
- The [Dovecot mailing lists](https://www.dovecot.org/mailinglists.html).
- The [Debian mailing lists](https://lists.debian.org/).
- Our [github page](https://github.com/progmaticltd/homebox).
- The [Ansible quick start](https://docs.ansible.com/ansible/latest/getting_started/index.html).
- Finally, [Duckduckgo](https://duckduckgo.com/) or [Google](https://google.com/).


## Folders content

The repository contains a few folders you should be familiar with:

- backup: The folder that contains some important files like the passwords and certificates generated when
  deploying the system. This allows you to "replay" the deployment on a new server after a disaster, without losing any
  information. This folder is generated automatically on the first deployment, and ignored by git.
- config: Your configuration files, specific to your platform and domain.
- config/defaults: The default pre-configured values and settings.
- devel: Role template and development specific files
- docs: This project documentation.
- playbooks: Ansible playbooks to install, uninstall or check the whole server environment.
- roles: The roles list. Each role has tasks to install, uninstall and check the system.
- sandbox: Put here anything you don't want to commit.
- scripts: utility scripts, for instance the domain selection script.


## Branches

- The current developments are done in the [dev](https://github.com/progmaticltd/homebox/tree/dev) branch.
- The main branch is kept for releases.


## Test machine

You can start to develop using a virtual machine on your workstation, for instance using KVM or VirtualBox. The
environment runs on Debian Stable. You can install it using a minimalistic ISO image, called
[netinst](https://www.debian.org/CD/netinst/).

I suggest you to use a virtual machine to test, especially with snapshots capabilities.  By using snapshots, you can
rollback to any stage and run the Ansible scripts again. On Linux, KVM/libvirt is the best choice, and VirtualBox might
be acceptable.

For instance:

`apt-get install libvirt virt-manager`


## Router configuration

Unless your IP address changes too often or your port 25 is blocked, you do not need to have a fixed IP address.

However, the more you want to test, the more your router need to be configured:

- UDP/53 (DNS): Used to query letsencrypt for the certificates. Open it at least to obtain the SSL using
  LetsEncrypt. You can then close the port once you have the certificates.
- TCP/25: SMTP, to receive and transfer emails from and to other SMTP servers on the internet. You need this one only to
  test the reception and transmission of external emails.

Now, all the rest can be done internally, without exposing your test machine. These ports don't need to be forwarded by
your router during the development time:

- TCP/143 and TCP/993: IMAP and IMAPS
- TCP/110 and TCP/995: POP3 and POP3S
- TCP/587: [Submission](https://en.wikipedia.org/wiki/Opportunistic_TLS).
- TCP/465: [SMTPS](https://en.wikipedia.org/wiki/SMTPS) (this one is kept for compatibility with some old devices)
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

I have actually tested with the Ansible remote user as root. However, it should be possible to run as an admin user and
use sudo with little modifications.


## System configuration

First, as you would do for a live environment, copy the sample configuration to create your own:

```sh
cd config
cp system-example.yml system.yml
```

The file is self explanatory, and inside, you will find the following block:

```yaml
system:
  release: bookworm
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


### Setting up ansible-lint before commit

The program ansible-lint is executed by the continuous integration platform, and should be used for each commit. A hook
is provided in the git-hooks folder.

The ansible-lint software needs to be installed on your machine. We are using the version in Debian Buster. The
ansible-lint configuration file is in `config/ansible-lint-default.yml`.

To ensure the hook is executed before each commit, run this on your local machine:

```sh
git config --local core.hooksPath git-hooks
```


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


## Some development tools to consider

- The fantastic tmux, mandatory IMHO: [tmux github page](https://github.com/tmux).
- Emacs or vim, but if you are not ready, [VisualStudio code](https://code.visualstudio.com/) is not too bad as well,
  and is very well integrated in Debian / Ubuntu.
- Test your SMTP server compliance: [mxtoolbox.com](http://mxtoolbox.com/).
- DNSSEC records debugger: https://dnssec-analyzer.verisignlabs.com/
- DNS propagation checker: https://www.whatsmydns.net/
