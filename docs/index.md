This is the home documentation for "Homebox", and set if Ansible scripts to deploy
a fully functional _and_ secure mail server at home or online.

The source code is on [GitHub](https://github.com/progmaticltd/homebox).

This project is for you if:

- You are interested to host your emails yourself, for privacy, security or any other reason.
- You want your server to be secure against both physical and remote intrusion.
- You want a low maintanance box that keep itself updated automatically.
- You prefer security and stability over latest features.
- You trust the Debian community to push security updates.

## Philosophy

- You should be able to upgrade anything installed via apt command. No git clone / wget / curl here, ever.
- If you are using your own hardware, the disk will be fully encrypted using
  [LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup). Nobody will be able to steal your hardware _and_ your
  information.
- AppArmor is activated on the first boot, and all the services are configured to support it. This makes your server
  very safe against remote intrusion, even when using 0-day vulnerabilities.
- You can set up multiple backup destination, local and remote, all encrypted.
- A lot of default choices made towards simplicity and [KISS principle](https://en.wikipedia.org/wiki/KISS_principle).
  and safety.
- Attention to details, keep focused on the nitty-gritty features of self hosting, like full IPv6 support.

## Main components

- Operating System: Debian Stretch (stable)
- Authentication: OpenLDAP
- Mail transfer agent: Postfix
- Mail delivery agent: Dovecot
- Monitoring: Zabbix
- Antispam: RSpamd
- Antivirus: ClamAV
- Webmail: RoundCube
- Groupware: Sogo
- Jabber: ejabberd
- DNS: bind9
- Bittorrent station: transmission
- Proxy: Privoxy / Tor
- Backup: Borgbackup

## Other projects to mention

If you are interested in self-hosting, you will find a lot of
interesting projects on internet, for instance:

- [Sovereign](https://github.com/sovereign/sovereign): A different
  target, but a similar deployment approach using Ansible.
- [yunohost](https://yunohost.org/): Contains a lot of plugins and
  features, not all of them are stable, but it is worth testing.
- [mailinabox](https://mailinabox.email/), more oriented to online
  hosting, but very good as well.
- [and many...](https://github.com/Kickball/awesome-selfhosted)

All have plenty of features, but maybe a different approach to
self-hosting, though.
