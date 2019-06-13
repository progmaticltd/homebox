# Automatic clients configuration

```yaml
mail_default:
  max_attachment_size: 25   # In megabytes
  autoconfig: true          # Support Thunderbird automatic configuration
  autodiscover: false       # Support MS Outlook automatic configuration (uses https)
```

The option “autoconfig” allows your users to automatically configure their email parameters in _Mozilla Thunderbird_.

For instance, for the domain homebox.space, this will create a subdomain entry "autoconfig.homebox.space"

The option “autodiscover” allows your _Microsoft Outlook_users to automatically configure their email parameters. For
instance, for the domain homebox.space, this will create a subdomain entry "autodiscover.homebox.space", accessible in
https, with a dedicated SSL certificate.

# Antivirus configuration

```yaml
mail:
  ...
  antivirus:                # Check inbound and outbound emails for viruses
    port: 34000             # port to use for the antivirus daemon
    active: true            # or false
    action: drop            # Action to do when a virus is found in an email: bounce or drop
                            # be careful, bouncing external emails is a way to expose clamav usage
    quarantine: yes         # Place emails with a virus in quarantine, for further analysis
    use_proxy: false        # use tor / privoxy to dowload updates
```

The platform can scan the emails received and sent, using [ClamAV](https://clamav.net/).

- You can disable the antivirus, by setting ‘active’ to false.
- By default, emails with viruses are dropped silently, but you can set the action to ‘bounce’ if you wish to send an
  alert to the external senders.

# Master users

As Dovecot is used, it is possible to activate the "impersonate" or _master users_ feature.  If you activate this
option, a _master_ user will be created, allowing you to logon as any user.  The RoundCube impersonate plugin will be
activated as well.

Example with this configuration:

```yaml
mail:
  …
  impersonate:
    active: true
    master: master
    separator: '/'
```

If one user is called john, you can now login as john, using "john/master" and the master user password.

The password is automatically generated, and saved in the backup folder, in the file __ldap/master.pwd__.

!!! Warning
    Every time the _master account_ feature is used, a notice is sent to the original user, both by email and with
    Jabber when installed.

# Import external accounts

There are two ways of importing other emails. The easiest way is to use SOGo web interface. In this case, you will see
your other account emails in the web interface.

The other option is to use the yaml configuration file. The advantage is once this set up, external emails will be
automatically imported in your main account, regardless of the client you are using.

This is detailed in the section [External accounts](external-accounts.md).

!!! Note
    One important thing to know is that this feature automatically creates a Dovecot _master user_, that will be used to
    import the emails into the folders. However, this master user can only log in from the system itself, so there is no
    danger of using the import user to access someone's emails. If someone tried the use the import account, the
    connection would be refused, and an email alert will be sent to the postmaster.

# Advanced features

When this flag is set to true, some advanced features will be
available, and a more recent version of Dovecot will be installed,
from the Debian backports repository.

## International email addresses

Your main email address should be without ASCII characters only, but the aliases can contains accents,
for instance:

``` yaml hl_lines="9"
users:
- uid: andre
  cn: André Rodier
  first_name: André
  last_name: Rodier
  mail: andre@homebox.space
  password: Xhlojwei$u987%
  aliases:
    - andré.rodier@homebox.space
    - andré@homebox.space
```

!!! Notes
    This is possible if all the software and the platforms involved support it. Not all major email providers are supporting
    this, Yahoo mail, for instance, does not even let you send an email with an internationalised user names.
    This feature is not entirely tested yet, but is working so far between two homebox servers and SOGo or evolution.

## Email addresses extensions

The flag "recipient_delimiter" let you send an email directly to a folder, by using a character to separate the email
address and the folder name with a character. The most common character is "+" although you can use any character.

Example with this configuration:

```yaml
mail:
  recipient_delimiter: '+'
```

For a user with an email address like __john@homebox.space__, any email sent to __john+lists@homebox.space__ will be
stored in the folder "lists".

!!! Note
    If the folder does not exists, the email will be placed in your INBOX.

## Custom Postfix options

You can add any compatible postfix configuration, by defining the variable "extra-settings" into your system.yml
file. In this case, anything this variable contains will be added into the main.cf file.  The [postfix
documentation](http://www.postfix.org/documentation.html) should help you.

Example: You want to send a copy of any email received to another external address, and allow the VRFY command:

``` yaml hl_lines="3 4 5"
mail:
  postfix:
    extra_settings: |
      always_bcc = spyme@fbi.gov.us
      disable_vrfy_command = no
```
