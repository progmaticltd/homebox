# Thunderbird automatic configuration

The option “autoconfig” allows your users to
automatically configure their email parameters in _Mozilla
Thunderbird_.

For instance, for the domain homebox.space, this will create
a subdomain entry "autoconfig.homebox.space"

# Outlook automatic configuration

The options “autodiscover” allows your users to
automatically configure their email parameters in
_Microsoft Outlook_. For instance, for the domain homebox.space,
this will create a subdomain entry "autodiscover.homebox.space"

An SSL certificate will be created as well.

# Antivirus configuration

The platform can scan the emails received and sent, using
[ClamAV](https://clamav.net/).

- You can disable the antivirus, by setting ‘active’ to false.
- By default, emails with viruses are dropped silently, but you can
  set the action to ‘bounce’ if you wish to send an alert to the
  external senders.

# Master users

As Dovecot is used, it is possible to activate the "impersonate" or
_master users_ feature.  If you activate this option, a _master_ user
will be created, allowing you to logon as any user.  The RoundCube
impersonate plugin will be activated as well.

Example with this configuration:

```yaml

  impersonate:
    active: true
    master: master
    separator: '/'

```

If one user is called john, you can now login as john, using
"john/master" and the master user password.

The password is automatically generated, and saved in the backup
folder, in the file __ldap/master.pwd__.

# Import external accounts

This is detailed in the section [External accounts](external-accounts.md).
One important thing to know is that this feature requires the creation
of a Dovecot _master user_, that will be used to import the emails into the folders.

# Advanced features

When this flag is set to true, some advanced features will be
available, and a more recent version of Dovecot will be installed,
from the Debian backports repository.

## International email addresses

The latest versions of dovecot in the Debian backports repository has
better unicode characters support, for email addresses and domains. If
you are planning to use them, it is better to set the flag
advanced_features to true.

__notes__

- This has not been intensively tested, and will require an entire
  documentation section.
- Not all major email providers are supporting this, Yahoo mail, for
  instance, does not support internationalised user names, like
  __andré@homebox.space__.

## Save emails into mail boxes directly

The flag "recipient_delimiter" let you send an email directly to a
folder, by using a character to separate the email address and the
folder name with a character. The most common character is "+"
although you can use any character.

Example with this configuration:

```yaml

  recipient_delimiter: '~'

```
For a user with an email address like __john@homebox.space__, any
email sent to __john~lists@homebox.space__ will be stored in
the folder "lists".

By default, the folder will be created and automatically subscribed if
it does not exists.  If you do not want this feature, you can override
the dovecot configuration, by creating this block in your system.yml
file:

```yaml

# Default dovecot packages to install
dovecot:
  packages:
    - dovecot-core
    - dovecot-imapd
    - dovecot-lmtpd
    - dovecot-pop3d
    - dovecot-managesieved
    - dovecot-sieve
    - dovecot-ldap
  settings:
    mail_max_userip_connections: 10
    lda_mailbox_autocreate: no
    lda_mailbox_autosubscribe: no

```

## Add Postfix options

You can add any compatible postfix configuration, by defining the
variable "posfix_add" into your system.yml file. In this case,
anything this variable contains will be added into the main.cf
file.
The [postfix documentation](http://www.postfix.org/documentation.html)
should help you.

Example: You want to send a copy of any email received to another
external address, and allow the VRFY command:

```yaml

mail:
  # [...]
  postfix_add: >-
    always_bcc = spyme@fbi.gov.uk
    disable_vrfy_command = no

```
