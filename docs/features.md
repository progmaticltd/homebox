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

You do not have to plug a screen and a keyboard to unlock your server. Once it is booted,
the server starts a small SSH server to connect, and let you enter the passphrase. The SSH
server is the excellent [dropbear](https://matt.ucc.asn.au/dropbear/dropbear.html),
and shares the public key with OpenSSH:
_You will not have the usual SSH warnings staying the signature has changed_.

It is also possible to use a Yubikey, with or without a passphrase, to decrypt your drive. In
this case, a safe script to enroll your key is provided.

## AppArmor enforcement

All the daemons are carefully configured with an AppArmor profile, in enforce mode. This
protects you against remote intrusion and 0-day vulnerabilities as well.

## Fail2ban integration

Fail2ban is integrated and configured, to automatically blacklist IP addresses used by
spammers to attack your server. It makes this kind of attacks inefficient, and saves your
bandwidth too.

The duration of jail is customisable for jabber and email services.

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

## Monitoring

The installer can deploy a complete monitoring solution, [Zabbix](https://zabbix.com).

- You can set up email or XMPP alerts, on various events.
- You can add other servers / machines to your monitoring server.
- You can set-up SMS alerts if, for instance, your internet connection goes down.

By default, the guest account is deleted, and a strong password is generated.

## Multiple IP scheme

Homebox can be configured with two static IP addresses, with a mix of IPv4 amd IPv6.

This is useful if you are using a VPN that provides you a static IP address or if you
are using 3G / 4G as a backup connection.

IPv6 is actually tested on [vultr.com](https://vultr.com/), a provider that supports full IPv6,
on virtual servers. Digital Ocean does not allows SMTP or Submission on IPv6.

# High profiles for SSL / HTTPS

All HTTPS sites are configured to use [HSTS](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security).
For nginx and dovecot, a 2048 Diffie-Helman parameter file is generated upon installation.
Ranked score A on [geekflare.com](https://tools.geekflare.com/) and A+ on [ssllabs.com](https://www.ssllabs.com).

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

## Roundcube Webmail

There are two webmail available. RoundCube, and SOGo.

RoundCube, comes with the following plugins / features activated by default:

- Archive
- Context Menu
- Emoticons
- Sieve Rules management, with vacation, automatic answers, etc…
- Mark as Junk
- New mail desktop notification
- Password modification
- IMAP Subscriptions management
- Hotkeys support (Ctrl+Enter to send an email)
- Log the real client IP address to the mail server

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

## Email access logging

Each access to the email server is logged in real time, with the following information:

- Source IP address
- Country
- Channel (RoundCube, SOGo or IMAP)

# Calendars and address books

## SOGo groupware

It is also possible to install SOGo, which offer collaborative features,
calendaring and address books. There are both accessible using respectively
CalDAV and CardDAV standards.

### Features of SOGo activated:

- Send emails reminder on events
- Vacation messages
- Forward your messages to another email address
- Sieve scripts editor
- Use the same web interface to access other emails
- Change your password from the web interface

More details on the [SOGo home page](https://sogo.nu/) and
on the official [documentation page](https://sogo.nu/support.html#/v3).

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

You can install the transmission bittorrent daemon, accessible over https on a dedicated
domain.

- The web interface and the RPC servers are protected with the LDAP credentials, unless you are at home.
- Downloaded files can be accessed within your web browser, still using the LDAP credentials if you are not at home.
- The daemon runs in a proper AppArmor profile.
- Easy to use form to search downloaded files in your web browser.

# Privoxy server

The platform configures Privoxy configured with the easylist rules by default, updated every day. The following rules
are activated by default:

- EasyList
- EasyPrivacy
- Fanboy's Annoyance List
- Fanboy's Social Blocking List

# Tor server

The platform configures Tor as well, and allows you to ooverride any option.
You can also chain privoxy and tor together.

# Other features

## DNSSEC Support

If you need a higher level of security and a protection agains DNS cache poisoning, you can
install a custom DNS server on your box, with support for DNSSEC extensions. Once the
playbook has been run, an email is sent to postmaster, with the ZSK (Zone Signing Key) and
KSK (Key Signing Key) attached.

The server installed is bind9. When activated, the server also publishes
[SSHFP](https://en.wikipedia.org/wiki/SSHFP_record) records for extra security.

## Single Packet Authorization port knocking

SPA is essentially next generation port knocking. It is using encryption and HMAC keys,
to open your firewall for an SSH connection.

- Supports HMAC authenticated encryption for both Rijndael and
  GnuPG.
- Replay attacks are detected and thwarted by SHA-256 digest
  comparison of valid incoming SPA packets.

More details explained on the [Comprehensive Guide](spa-fwknop).

## DNS automatic update

If you are using Gandi as your DNS provider, the installation script can automatically
create DNS entries for your mail server.

## LetsEncrypt certificates management

Automatically generate certificates for each services, using LetsEncrypt. The certificates
are saved on the deployment workstation as well, and reused if you are deploying your
server again.

## Basic sites creation

The system can create a skeleton for a static web site for you, with two https
certificates as well. The certificates created, for instance for the domain example.com,
will be www.example.com and example.com.

You can also use [Hugo](https://gohugo.io/) and its [numerous themes](https://themes.gohugo.io/)
to create your site. The nginx server will be configured as a reverse proxy for your site,
using a systemd Hugo service.

The hugo web site content need to be placed in the backup folder:

`backup/\<domain-name\>/website-hugo/`

The site will be synchronised on the server, and served by Hugo systemd daemon, protected by
AppArmor.

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
