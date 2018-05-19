![Documentation status](https://readthedocs.org/projects/homebox/badge/?version=latest)

Official documentation and user's guide: http://homebox.readthedocs.io/en/latest/

A set of Ansible scripts to setup a secure email and personal files server. This project is for you if:

- You are interested to host your emails yourself, for privacy, security or any other reason.
- You want your server to be secure against both physical and remote intrusion.
- You want a low maintenance box that keep itself updated automatically.
- You trust the Debian community to push security updates.

## Current status and supported features

For a complete list of features, see the
[official documentation](http://homebox.readthedocs.io/en/latest/features/).


| Current feature, implemented and planned                                                                            | Status      |  Tested   |
| ------------------------------------------------------------------------------------------------------------------- | :---------: | :-------: |
| LDAP users database, SSL & TLS certificates, password policies, integration with the system and PAM.                | Done        | Automatic |
| SSL Certificates generation with [letsencrypt](https://letsencrypt.org), automatic local backup and publication.    | Done        | Automatic |
| DKIM keys generation and automatic local backup and publication on Gandi                                            | Done        | Automatic |
| SPF records generation and publication on Gandi                                                                     | Done        | Automatic |
| DMARC record generation and publication on Gandi, *the reports generation is planned for a future version*          | Done        | Automatic |
| Generation and publication of automatic Thunderbird (autoconfig) and Outlook (autodiscover) configuration           | Done        | Automatic |
| Postfix configuration and installation, with LDAP lookups, and protocols STARTTLS/Submission/SMTPS                  | Done        | Automatic |
| Automatic copy of sent emails into the sent folderm ala GMail                                                       | Done        | Automatic |
| Powerful and light antispam system with [rspamd](https://rspamd.com/)                                               | Done        |  Manual   |
| Dovecot configuration, IMAPS, POP3S, Quotas, ManageSieve, Spam and ham autolearn, Sieve auto answers, impersonate   | Done        |  Basic    |
| Roundcube webmail, https, sieve filters management, password change, automatic identity creation                    | Done        |  Basic    |
| AppArmor securisation for rspamd, nginx, dovecot, postfix, clamav                                                   | Done        |  Manual   |
| ISO image builder, for automatic Debian installation and a fully encrypted with LUKS ([preseed](docs/preseed.md))   | Done        |  Manual   |
| Antivirus for inbound / outbound emails with [clamav](https://www.clamav.net/) without blocking the SMTP session.   | Done        | Automatic |
| Add your GMail, Yahoo, Outlook.com or standard IMAP accounts.  See [external accounts](docs/external-accounts.md)   | Done        |  Manual   |
| Multiple encrypted incremental backups, with email reporting. See [backup documentation](docs/backup.md) for details| Done        |  Manual   |
| Dovecot full text search in emails, attachments and attached archives.                                              | Done        | Automatic |
| Jabber server, using [ejabberd](https://www.ejabberd.im/) with LDAP authentication and file transfer                | Done        |  Manual   |

### Prerequisites

- A workstation to run the Ansible scripts.
- If you want to host the server at home, a static IP address from your ISP.
- A server plugged on your router or a virtual machine for testing.

#### Note on AppArmor

AppArmor is activated by default, unless you disable it in the
configuration file.  The script will reboot the server to activate
AppArmor if it is not active.  If you have installed the system using
the _preseed_ installer, your server has already activated AppArmor on
boot.

## Future versions

I am planning to test / try / add the following features, in *almost*
no particular order:

- Install [Sogo](https://sogo.nu/) for caldav / carddav server, with
  of course LDAP authentication.
- Add optional components (e.g. [Gogs](https://gogs.io/),
  [openvpn](https://openvpn.net/),
  [Syncthing](https://syncthing.net/), etc).
- Use Lexicon for DNS updates: https://github.com/AnalogJ/lexicon.

## Other projects to mention

There are other similar projects on internet and especially github you could check, for instance:

- [Sovereign](https://github.com/sovereign/sovereign): A different
  target, but a similar deployment approach using Ansible.
- [yunohost](https://yunohost.org/): Contains a lot of plugins and
  features, not all of them are stable, but it is worth testing.
- [mailinabox](https://mailinabox.email/), more oriented to online
  hosting, but very good as well.
- [and many...](https://github.com/Kickball/awesome-selfhosted)

All have plenty of modern features that may suits you as well.
