# Backup and disaster recovery

## Debian ISO image builder

You can generate an ISO image to install Debian on your server, using a simple configuration
file in YAML format.

This will make a quick re-installation disk for the system. It will configure for you full
disk encryption and *AppArmor* support straight on the first boot.

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
A summary email is sent at the end of the backup process, both in case of success and failure.

# Security

## Full disk encryption

When you are using the ISO image builder to install Debian, the server disk will be fully
encrypted using LUKS, with the passphrase specified in a configuration file.

This makes your server fully secure against physical intrusion, if your hardware is
stolen.

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
to re-use the same passwords, or use a password too similar than the previous ones.

# Email features

## Digital signature

A DKIM certificate of 4096 bits is generated during the installation, and the associated
public key is published on the DNS server.

The SPF and DMARC records are generated and published automatically as well.

This will guarantee your emails being recognised by other email servers without any
problem.

## Address extension

When registering on a service, you can use address extensions, to directly receive emails
in a specific folder. For instance, emails to john+lists@example.com will be directly saved
into the 'lists' folder of your IMAP server.

Email folders can be automatically created and subscribed as well.

## Sieve filtering

Sieve filtering support, with automatic answering, vacation, regular expression, custom
scripts support, etc. The web interface to configure your filters is powerful but easy to
use.

You can also access your sieve filters with the _ManageSieve_ protocol, and the
[Thunderbird extension](https://addons.mozilla.org/en-US/thunderbird/addon/sieve/).

## Automatic client configuration

The server supports _Mozilla Thunderbird_, _Microsoft Outlook_ and other email clients
automatic configuration. This makes the life of your users easier. It creates and publish
autoconfig.xml, autodiscover.xml and DNS records (RFC 6186).

## Antivirus

The emails received are automatically checked for viruses, and are dropped by default
if they contain one. The emails sent by your users are checked as well, avoiding your
IP address to be blacklisted if one of your account is compromised. In the second case,
the system can also send a warning with the IP address of the sender.

You can also choose to explicitly reject (bounce) emails containing viruses.

In all case, the analysis is done after the email queue, making the process non blocking
and efficient on small resourced hardware.

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

## Automatic copy to the sent folder

You do not need to configure your mail client to copy emails to the sent folder, this is
done automatically for you. This is a lot of time saved, especially when sending big
emails with attachments: You don't need to upload an email twice.

# Other features

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
