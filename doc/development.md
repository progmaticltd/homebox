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

## Playbooks

There is one main playbook 'main.yml', that includes playbooks for individual tasks:

- autoconfig.yml
- autodiscover.yml
- cert-imap.yml
- cert-pop3.yml
- cert-smtp.yml
- dns-update.yml
- dovecot.yml
- homes.yml
- ldap.yml
- opendkim.yml
- opendmarc.yml
- postfix.yml
- roundcube.yml
- rspamd.yml
- system-prepare.yml

There is also a test playbook 'test.yml', to run integration tests on your mail server.

