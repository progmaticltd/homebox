A set of Ansible scripts to setup a secure email and personal files server. This project is for you if:

- You are interested to host your emails yourself, for privacy, security or any other reason.
- You want your server to be secure against both physical and remote intrusion.
- You want a low maintenance box that keep itself updated automatically.
- You trust the _Debian community_ to publish security updates.


## Official documentation and user's guide

- [Stable branch](http://homebox.readthedocs.io/en/main/)
- [Development branch](http://homebox.readthedocs.io/en/dev/)

## Following the development using RSS feeds

- [Stable branch](https://github.com/progmaticltd/homebox/commits/main.atom)
- [Development branch](https://github.com/progmaticltd/homebox/commits/dev.atom)

## Mailing lists

Thanks to [Framasoft](https://framasoft.org/), two mailing lists have been created, one for general questions,
suggestions and support, and another one dedicated for development.

- General questions: https://framalistes.org/sympa/info/homebox-general
- Development: https://framalistes.org/sympa/info/homebox-dev


## Current project status


### System installation and features

- Install packages only from Debian stable (Bookworm).
- Automatic [letsencrypt](https://letsencrypt.org) certificates generation using DNS challenge.
- Automatic security updates.
- Centralised authentication with an LDAP users database and password policies.
- AppArmor activated, with a profile for all daemons.
- Random passwords generated and saved using [pass](https://passwordstore.org).
- Can be used at home, on a dedicated or virtual server hosted online.
- Flexible IP address support: IPv4 only, IPv6 only, and IPv4+IPv4 or IPv4+IPv6.
- Embedded DNS server, with CAA, DNSSEC and SSH fingerprint (SSHFP records).
- All the http sites ranked **A+**, with HSTS implemented out of the box.
- Automatic firewall rules for inbound, outbound and forwarding traffic, using nftables.
- Restricted outbound traffic to the minimum.
- Automatic update of DNS servers and glue records on Gandi.
- Automatic configuration of OpenPGP Web Key Directory.


### Emails

- Postfix configuration and installation, with LDAP lookups, internationalised email aliases,
  fully SSL compliant.
- Generate DKIM keys, SPF and DMARC DNS records. The DKIM keys are generated every year.
- Automatic copy of sent emails into the sent folder.
- Automatic creation of the postmaster account and special email addresses using
  [RFC 2142](https://tools.ietf.org/html/rfc2142) specifications.
- Dovecot configuration, IMAPS, POP3S, Quotas, ManageSieve, simple spam and ham learning
  by moving emails in and out the Junk folder, sieve and vacation scripts.
- Virtual folders for server search: unread messages, conversations view, all messages, flagged
  and messages labelled as "important".
- Email addresses with recipient delimiter included, e.g. john.doe+lists@dbcooper.com.
- Optional master user creation, e.g. for families with children or moderated communities.
- Server side full text search inside emails, attached documents and files and
  compressed archives, with better results than GMail.
- Modern and responsive web access to emails, calendars and address books.
- Powerful and light antispam system with [rspamd](https://rspamd.com/) and optional access to the web interface.
- Antivirus for inbound _and_ outbound emails with [clamav](https://www.clamav.net/).
- Automatic configuration for Thunderbird and Outlook using published XML and other clients with
  special DNS records ([RFC 6186](https://tools.ietf.org/html/rfc6186)).


### Calendar and Address book

- Install and configure a CalDAV / CardDAV server, with automatic discovery ([RFC 6186](https://tools.ietf.org/html/rfc6764)).
- Groupware functionality in a web interface, with [SOGo](https://sogo.nu/).
- Recurring events, email alerts, shared address books and calendars.
- Mobile devices compatibility: Android, Apple iOS, BlackBerry 10 and Windows mobile through Microsoft ActiveSync.


### Other optional features

- Static web site skeleton configuration, with https certificates and A+ security grade.
- Jabber server, using [ejabberd](https://www.ejabberd.im/), with LDAP authentication, direct or offline file transfer
  and optional server to server communication.
- Incremental backups, encrypted, on multiple destination (SFTP, S3, Samba share or USB drive), with email and Jabber
  reporting.


### Development

- YAML files validation on each commit, using [travis-ci](https://travis-ci.org/progmaticltd/homebox).
- End to end integration tests for the majority of components.
- Playbooks to facilitate the installation or removal of development packages.
- Global debug flag to activate the debug mode of all components.
- Fully open source Ansible scripts licensed under GPLv3.
