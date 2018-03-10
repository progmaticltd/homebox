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

## DKIM Keys: 'dkim-keys'

This folder contains the DKIM keys generated on the server. The installation script will compare these DKIM public key with the one recorded in your DNS, and will update it only if different.

## LDAP passwords:

This folder contains the passwords generated automatically for some accounts in the LDAP directory

  - admin.pwd: Super administrator password, read/write on the entire LDAP system
  - manager.pwd: Manager: read/write access to user accounts
  - readonly.pwd: readonly account to query the ldap server

