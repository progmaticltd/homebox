# Automatic backup

The files in these folders are excluded from the git repository.
When deploying for the first time, they will contain some important files, to avoid being regenerated every time you are running the Ansible scripts.

This is useful, both for archiving purposes and during the development phase.

## Certificates

This folder contains the letsencrypt certificates generated on the server. This is also very important, to avoid requesting the certificates again and again, and being blocked by LetsEncrypt.

For instance, this is the certificates generated, for the domain "homebox.space"

  - imap.homebox.space
  - ldap.homebox.space
  - smtp.homebox.space
  - webmail.homebox.space
  - autodiscover.homebox.space (when using autodiscover from Outlook)

## DKIM Keys: 'dkim-keys'

This folder contains the DKIM keys generated on the server. The installation script will compare these DKIM public key with the one recorded in your DNS, and will update it only if different.

## LDAP passwords

This folder contains the passwords generated automatically for some accounts in the LDAP directory

  - admin.pwd: Super administrator password, read/write on the entire LDAP system
  - manager.pwd: Manager: read/write access to user accounts
  - readonly.pwd: readonly account to query the ldap server
  - import.pwd: Master account used to inject imported external emails into the user's emails.
  - postmaster.pwd: Postmaster account, that receives, for instance, emails
    like postmaster@domain.com or webmaster@domain.com.

## Password for the rspamd administration interface

The Antispam comes with an excellent [web interface](https://www.rspamd.com/webui/) that provides basic functions for setting metric actions, scores, viewing statistic and learning.