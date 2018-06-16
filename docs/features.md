# Backup and disaster recovery

## Debian ISO image builder

You can generate an ISO image to install Debian on your server, using a simple configuration
file in YAML format.

This will make a quick re-installation disk for the system. It will configure for you full
disk encryption and *AppArmor* support straight on the first boot. It is not made to
install the software stack, that need to be deployed with Ansible, from a remote
workstation. Although it might be possible to integrate the deployment scripts into the ISO
image.

## Deployment information backup

When you are deploying the system for the first time, all the information generated is
saved on the deployment workstation. This allows you to _replay_ the installation without
loosing any information and without having to change your DNS records.

The information backed up includes DKIM keys, SSL certificates, special account passwords,
encryption keys, etc.

## Multiple encrypted backups

You can setup multiple backups for your user's home folders, remote or local, with
multiple frequencies as well. For instance, one daily backup on your NAS using a Samba
share, and a weekly backup on a remote server using SSH.<br />
All the backups are encrypted and managed by the excellent _borgbackup_ package.
A [summary email](/backup/#emails-reporting) is sent at the end of the backup process,
both in case of success and failure.

# Security

## Full disk encryption

When you are using the ISO image builder to install Debian, the server disk will be fully
encrypted using LUKS, with the passphrase specified in a configuration file.

This make your server fully secure against physical intrusion, even if your hardware is
lost or stolen.

## AppArmor enforcement

All the daemons are carefully configured with an AppArmor profile, in enforce mode. This
protects you against remote intrusion and 0-day vulnerabilities as well.

## Fail2ban integration

Fail2ban is integrated and configured, to automatically blacklist IP addresses used by
spammers to attack your server. It makes this kind of attacks inefficient, and saves your
bandwidth too.

## LDAP Authentication

All the user accounts are saved in the LDAP database, using the OpenLDAP package in
Debian. A dedicated SSL certificate is created during the installation, allowing secure
SSL and TLS communication with the server.

## Password policies

Password complexity is enforced at system level, using
[pwquality module](https://packages.debian.org/stretch/libpam-pwquality).
You can specify minimum length, mandatory characters like symbols and a mix of lowercase /
uppercase letters. You can also remember the last passwords for each users, avoiding them
to re-use the same passwords or use a password too similar than the previous ones.

## Automatic security update

Once your system is installed, any security update will be installed in background,
without you having to do anything. This is set using the
[Debian unattended upgrades](https://wiki.debian.org/UnattendedUpgrades)
package.  If you prefer to install security updates yourself, you can disable this
behaviour in your system.yml file.

Only the security updates are installed, new packages versions still need to be installed
manually.

# Email features

## Digital signature

A DKIM certificate of 4096 bits is generated during the installation, and the associated
public key is published on the DNS server. The DKIM key purpose is to mark emails coming
from your domain as authentic.

The SPF and DMARC records are generated and published automatically as well.

This will guarantee your emails being recognised by other email servers without any
problem.

## Internationalised email aliases

You can add as many email aliases as you want for your user accounts. Moreover, you will
be able to add email addresses with internationalised characters, using a standardised
LDAP schema.

You can then have email addresses like andré@homebox.space, or even аджай@экзампл.рус.

## Address extension

When registering on a service, you can use address extensions, to directly receive emails
in a specific folder. For instance, emails to __john+lists@example.com__ will be directly
saved into the __‘lists’__ folder of your IMAP server.

Email folders can be automatically created and subscribed as well, and you can use any
character to separate your email address. for instance ‘:’, ‘~’, ‘/’ etc.

## Sieve filtering

Sieve filtering support, with automatic answering, vacation, regular expression, custom
scripts support, etc. The web interface to configure your filters is powerful but easy to
use.

You can also access your sieve filters with the _ManageSieve_ protocol, and the
[Thunderbird extension](https://addons.mozilla.org/en-US/thunderbird/addon/sieve/).

For instance, you can automaticaly:

- move/copy messages to specified folder
- redirect/copy messages to another account
- discard messages with a specific error message
- reply automatically, using vacation at specific dates
- delete messages
- sett flags (e.g. flag, mark as read, etc.)

## Full text search

The server implements full text search inside your emails _and_ your attachments.
Full text search is also done inside attached archives (zip, rar, etc). The following
attachments types are actually recognised:

- PDF files.
- Text, XML and HTML files (various encoding)
- Microsoft Office documents: doc, docx, xls, xlsx, pptx.
- LibreOffice/OpenOffice documents: ods, odt, odp, sxw.
- Other office documents: csv, rtf, gnumeric and abiword files
- E-Books (epub)
- Attached emails (eml)
- Archives: (zip, tar, rar, gzip)
- Old microsoft archive format: tnef (aka winmail.dat)

Archives are opened recursively, until finding documents to parse.

__Notes and Limitations:__

- Although encrypted archives cannot be opened, the file list is indexed.
- Powerpoint files before 2003 (.ppt) are not well supported.

More formats could be added once Apache Tika will be included in Debian Stable.

## Master user

Whatever you use your email server for a community or a family, you can activate the
"impersonate" function. This function creates a "master" user, with an access to every
other user's mail boxes.

This feature is disabled by default, and the next version will send an alert in real time
to the user when this functionality is used. It is mainly meant for family and children
with an email address.

## Automatic client configuration

The server supports _Mozilla Thunderbird_, _Microsoft Outlook_ and other email clients
automatic configuration. This makes the life of your users easier. It creates and publish
autoconfig.xml, autodiscover.xml and DNS records
([RFC 6186](https://tools.ietf.org/html/rfc6186)).

## Antivirus

The emails received are automatically checked for viruses, and are discarded by default
if they are infected. The emails sent by your users are checked as well, avoiding your
IP address to be blacklisted if one of your account is compromised.

In the later case, the system can also send a warning with the IP address of the sender
for a remote address:

```html

Hello,

A virus has been sent using your email address (andre@homebox.space).

- The virus is identified by ClamAV as "Clamav.Test.File-6".
- The remote IP address is "106.57.174.35".
- The intended recipient(s) were:
  - mirina@homebox.space

The email has been discarded and not transferred, please:

- Check your workstation for viruses,
- Change your password, using https://webmail.homebox.space/
- Download an antivirus, for instance at https://www.clamav.net/

More details about the source IP address:
https://getmyipaddress.org/ipwhois.php?ip=106.57.174.35

--
The Postmaster

```

When the email is sent from your network, the MAC address is added to the email warning:

```html

Hello,

A virus has been sent using your email address (andre@homebox.space).

- The virus is identified by ClamAV as "Clamav.Test.File-6".
- The remote IP address is "172.16.1.39".
- The intended recipient(s) were:
  - john@homebox.space

The email has been discarded and not transferred, please:

- Check your workstation for viruses,
- Change your password, using https://webmail.homebox.space/
- Download an antivirus, for instance at https://www.clamav.net/

More details about the source IP address:
MAC address: 26:ac:5b:6a:4d:ac

--
The Postmaster

```

You can also choose to explicitly reject (bounce) emails containing viruses. In all case,
the analysis is done after the email queue, making the process non blocking and efficient
on small resourced hardware.

## Antispam with automatic learning

The antispam integrated with the system is very easy to use. The automatic learning is
done just by moving emails out or in the Junk email folder.

It is powered by rspamd, a pioneered application in term of junk email detection.

## External accounts import

You can add other email accounts (Yahoo, GMail, Outlook.com, etc.). The emails will be
automatically downloaded and synchronised when you connect with any client, and will
appear in your account.

Because the folders hierarchy will be copied as well, it is possible to migrate from
another account very easily.

## Webmail

The current webmail installed is RoundCube, with the following plugins / features
activated by default:

- Archive
- Context Menu
- Emoticons
- Sieve Rules management, with vacation, automatic answers, etc…
- Mark as Junk
- New mail desktop notification
- Password modification
- IMAP Subscriptions management
- Thunderbird labels
- Hotkeys support (Ctrl+Enter to send an email)

When the master user functionality has been activated, the impersonate plugin is also
installed, allowing you to inspect any user's emails from the webmail.

More plugins can be activated very easily, just by specifying their name in the list of
plugins:

- dkimstatus
- hide_blockquote
- zipdownload
- new_user_dialog
- additional_message_headers
- acl
- database_attachments
- debug_logger
- help
- hide_blockquote
- http_authentication
- show_additional_headers
- squirrelmail_usercopy
- userinfo
- vcard_attachments
- virtuser_file
- virtuser_query


## Automatic copy to the sent folder

You do not need to configure your mail client to copy emails to the sent folder, this is
done automatically for you. This is a lot of time saved, especially when sending big
emails with attachments: You don't need to upload an email twice.

# XMPP / Jabber server

The installation script can install an XMPP / Jabber server, by using
[ejabberd](https://www.ejabberd.im/),
a _Rock Solid, Massively Scalable, Infinitely Extensible XMPP Server_.

## Client to Server

- The authentication is using the LDAP server.
- Generate a 2048 bits Diffie-Helman key.
- Encryption enforcement, at least TLS 1.2.
- Jabber Fail2Ban integration
- Grade A on [IM Observatory](https://xmpp.net/index.php) client and server reports.
- SOCKS5 Bytestreams file transfers with image thumbnails (pidgin, empathy, etc.).
- Offline file sending using https on a dedicated sub-domain (Android Conversations, etc.).
- Automatically add contact (rosters) from the shared directory.
- VCard generation from the LDAP server.
- Message archives on the server, with archive management from the client (MAM).
- User avatars are stored on the server.
- Conference / chat rooms between multiple domains.

## Server to Server

The installation scripts can also activates server to server communication (aka s2s).
This is optional but activated by default. It is also possible to restrict access
to trusted servers, by specifying a list of domain names you want to trust.

Some clients: [XMPP client software](https://xmpp.org/software/clients.html).

# Gogs git server

You can optionally install a small, fast and light git server called
[gogs](https://gogs.io/). The server is configured with the following features:

- HTTPS certificate
- LDAP authentication
- Automatic update
- Two factors authentication
- Repository mirror

# Bittorrent server with a web interface

You can install the trnsmission bittorrent daemon, accessible over https on a dedicated
domain.

The daemon runs in a proper AppArmor profile.

# Other features

## DNSSEC Support

If you need a higher level of security and a protection agains DNS cache poisoning, you can
install a custom DNS server on your box, with support for DNSSEC extensions. Once the
playbook has been run, an email is sent to postmaster, with the ZSK (Zone Signing Key) and
KSK (Key Signing Key) attached.

The server installed is bind9. When activated, the server also publishes
[SSHFP](https://en.wikipedia.org/wiki/SSHFP_record) records for extra security.

## DNS automatic update

If you are using Gandi as your DNS provider, the installation script can automatically
create DNS entries for your mail server.

## LetsEncrypt certificates management

Automatically generate certificates for each services, using LetsEncrypt. The certificates
are saved on the deployment workstation as well, and reused if you are deploying your
server again.

## Static web site creation

The system can create a skeleton for a static web site for you, with two https
certificates as well. The certificates created, for instance for the domain example.com,
will be www.example.com and example.com.

## Modular components

Although All the components are well integrated together, it is possible to replace them
by another one, or to remove them. For instance, the RoundCube webmail is optional, as
well as automatic configuration modules for _Mozilla Thunderbird_ and _Microsoft Outlook_.

# Development Features

## Included debug

When you will deploy the server for the first time, on when you are developing, you can
set a global "debug" flag. This will activate the verbose or debug logging option of every
service. Just using systemctl, you will be then able to filter by service. Once
everything is working, set the flag back to false, run the deployment script again, and
you have a sever ready for production.

## Integrated testing

Until we have a full testing environment, perhaps based on virtualisation, you are already
able to test the most important features of your server, automatically, with one command,
with an Ansible playbook. This test playbook is running self diagnostic tasks on your
server, and test the following:

- Basic OS tests
- LDAP server
- Home folders
- Antispam (rspamd)
- Antivirus (clamav)
- OpenDMARC
- Certificates for all services
- DKIM keys (opendkim)
- Postfix configuration
- IMAP access (dovecot
- Autoconfig and Autodiscover
- DNS records when the DNS server is installed

## Development support playbook

A playbook add support for development packages, necessary to debug and diagnostic
the system while you are developing it, like SMTP or DNS tools. Once the development is
finished, another playbook remove these packages and cleanup the system.
