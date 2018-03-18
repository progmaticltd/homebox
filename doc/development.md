# Testing / Developing

The current development are done in the [development](https://github.com/progmaticltd/homebox/tree/dev) branch.

Whatever you have a fixed IP address or not, you can start to develop using a virtual machine on your workstation, if the router is correctly configured.

There is a preseed folder to create an ISO image for development, by using snapshots, you can rollback to any stage and run the Ansible scripts again.

## Router configuration

- your router should forward a few ports to your virtual machine:
  - TCP/80 : Used to query letsencrypt for the certificates
  - TCP/25 : SMTP, to receive emails
- The other ports open don't need to be forwarded by your router during the development time:
  - TCP/143 and TCP/993 : IMAP and IMAPS
  - TCP/110 and TCP/995 : POP3 and POP3S
  - TCP/465 and TCP/587 : [SMTPS](https://en.wikipedia.org/wiki/SMTPS) and [Submission](https://en.wikipedia.org/wiki/Opportunistic_TLS) (the former is kept for compatibility with some old devices)
  - TCP/4190 : ManageSieve
  - TCP/443 : HTTPS access for the webmail

I am planning to add a step to open the ports automatically wit UPNP.

## System configuration

In your config/system.yml, use the following values 

```
system:
  release: stretch
  login: true
  ssl: letsencrypt
  devel: true
  debug: true
```

There is also a development branch called buster-dev, for the next Debian version.

## Installatin playbooks

There is one main playbook 'main.yml', that includes playbooks for individual tasks:

- system-prepare.yml
- ldap.yml          
- homes.yml         
- rspamd.yml        
- opendmarc.yml     
- cert-smtp.yml     
- opendkim.yml      
- postfix.yml       
- dns-update.yml    
- cert-pop3.yml     
- cert-imap.yml     
- dovecot.yml       
- roundcube.yml     
- autodiscover.yml  
- autoconfig.yml    

## Development playbook

The playbook "dev-support.yml" installs some diagnostic and convenience packages on the server, to make your life easier during the development phase. By defaults, these packages are installed:

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

The script also configures bashrc / zsh.

## Development cleanup

The playbook do the opposite of dev-support, by uninstalling the packages used for development, and restoring the bashrc to its default state. You probably want to run this script before putting your server in production.

## Tests / Diagnostic playbook.

There is also a test playbook 'tests.yml'. This playbook runs a list of system and integration tests on your server. This is useful for diagnostic purposes, and also during the development phase, to be sure nothing is broken.

The following roles are run:

- Install the development packages above:
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

