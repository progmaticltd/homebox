
![Documentation status](https://readthedocs.org/projects/homebox/badge/?version=latest)
[![Build Status](https://travis-ci.org/progmaticltd/homebox.svg?branch=master)](https://travis-ci.org/progmaticltd/homebox)


A set of Ansible scripts to setup a secure email and personal files server. This project is for you if:

- You are interested to host your emails yourself, for privacy, security or any other reason.
- You want your server to be secure against both physical and remote intrusion.
- You want a low maintenance box that keep itself updated automatically.
- You trust the Debian community to publish security updates.

[Official documentation and user's guide](http://homebox.readthedocs.io/en/latest/)

## Current status and supported features

For a complete list of features, see the
[features page](http://homebox.readthedocs.io/en/latest/features/)
in the official documentation.

### System installation and features

- Custom Debian installer generation with full disk encryption and fully automatic installation.
- Install packages only from Debian stable (Stretch) or officially maintained repositories (rspamd).
- Automatic SSL Certificates generation with [letsencrypt](https://letsencrypt.org).
- Automatic security updates (optional).
- Single Sign On with an LDAP users database, SSL certificate, password policies, PAM
  integration.
- AppArmor activated by default, profiles for all daemons.
- Automatic backup of the deployment data to replay the installation with the same data.
- Can be used at home, on a dedicated or virtual server hosted online.

### Emails

- Postfix configuration and installation, with LDAP lookups, internationalised email aliases,
  fully SSL compliant.
- Generate DKIM keys, SPF and DMARC DNS records.
- Automatic copy of sent emails into the sent folder.
- Automatic creation of the postmaster account and special email addresses using
  [RFC 2142](https://tools.ietf.org/html/rfc2142) specifications.
- Dovecot configuration, IMAPS, POP3S, Quotas, ManageSieve, simple spam and ham learning
  by moving emails in and out the Junk folder, sieve and vacation scripts.
- Virtual folders for server search: unread messages, conversations view, all messages, flagged messages.
- Email addresses with recipient delimiter included, e.g. john.doe+lists@dbcooper.com.
- Optional master user creation, e.g. for families with children or moderated communities.
- Server side full text search inside emails, attached documents and files and
  compressed archives, with better results than GMail.
- Optional Roundcube webmail with sieve filters management, password change form, automatic identity
  creation, master account access, etc.
- Automatic import emails from Google Mail, Yahoo, Outlook.com or any other standard IMAP account.
- Powerful and light antispam system with [rspamd](https://rspamd.com/) and optional access to the web interface.
- Antivirus for inbound _and_ outbound emails with [clamav](https://www.clamav.net/) and email alerts.
- Automatic configuration for Thunderbird and Outlook using published XML and other clients with
  special DNS records ([RFC 6186](https://tools.ietf.org/html/rfc6186)).

### Other optional features

- Incremental backups, encrypted, on multiple destination (SFTP, Samba share or USB drive), with email reporting.
  See [backup documentation](docs/backup.md) for details.
- Jabber server, using [ejabberd](https://www.ejabberd.im/), with LDAP authentication,
  direct or offline file transfer and optional server to server communication.
- Embedded DNS server with DNSSEC and SSHFP (SSH fingerprint) records support
- Automatic publication of DNS entries to Gandi DNS.
- External IP address detection.
- Static web site skeleton configuration, with https certificates.

### Development

- YAML files validation on each commit, using [travis-ci](https://travis-ci.org/progmaticltd/homebox).
- End to end integration tests for the majority of components.
- Playbooks to facilitate the installation or removal of development packages.
- Global debug flag to activate the debug mode of all components.
- Fully open source Ansible scripts licensed under GPLv3.
