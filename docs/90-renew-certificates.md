# Renew the certificates

Once your DNS server is live, it's to to built the real certificates, using a simple command.

```sh
root@bochica ~# cert-renew
```

The first time it is run, this command should takes some significant time, and will create all the certificates using
LetsEncrypt certificate authority. Once run, the `cert-status` command should give you something like this:

```plain
root@bochica ~# cert-status
Domain      | Valid from                | Valid until               | Days left  | Issuer  | Full domains list             | Status
imap        | Dec 27 12:02:40 2023 GMT  | Mar 26 12:02:39 2024 GMT  | 71         | R3      | DNS:imap.sweethome.box        | OK
homebox     | Dec 27 12:09:09 2023 GMT  | Mar 26 12:09:08 2024 GMT  | 71         | R3      | DNS:sweethome.box             | OK
main        | Dec 27 12:09:20 2023 GMT  | Mar 26 12:09:19 2024 GMT  | 71         | R3      | DNS:main.sweethome.box        | OK
www         | Dec 27 12:09:31 2023 GMT  | Mar 26 12:09:30 2024 GMT  | 71         | R3      | DNS:www.sweethome.box         | OK
*           | Dec 27 12:09:42 2023 GMT  | Mar 26 12:09:41 2024 GMT  | 71         | R3      | DNS:*.sweethome.box           | OK
pop         | Dec 27 12:22:19 2023 GMT  | Mar 26 12:22:18 2024 GMT  | 71         | R3      | DNS:pop3.sweethome.box        | OK
autoconfig  | Dec 27 12:25:45 2023 GMT  | Mar 26 12:25:44 2024 GMT  | 71         | R3      | DNS:autoconfig.sweethome.box  | OK
smtp        | Dec 27 12:26:28 2023 GMT  | Mar 26 12:26:27 2024 GMT  | 71         | R3      | DNS:smtp.sweethome.box        | OK
ldap        | Dec 27 12:27:18 2023 GMT  | Mar 26 12:27:17 2024 GMT  | 71         | R3      | DNS:ldap.sweethome.box        | OK
mta         | Dec 27 12:30:30 2023 GMT  | Mar 26 12:30:29 2024 GMT  | 71         | R3      | DNS:mta-sts.sweethome.box     | OK
sogo        | Dec 28 07:56:24 2023 GMT  | Mar 27 07:56:23 2024 GMT  | 72         | R3      | DNS:sogo.sweethome.box        | OK
rspamd      | Dec 28 12:48:18 2023 GMT  | Mar 27 12:48:17 2024 GMT  | 72         | R3      | DNS:rspamd.sweethome.box      | OK
root@bochica ~#
```

Once you have renewed the certificates, you can probably reboot the system.
