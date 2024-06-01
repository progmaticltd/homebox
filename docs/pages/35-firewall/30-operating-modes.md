# Operating modes

To limit brute force traffic, especially on the SSH port, inbound rules have three modes of operation possible.

1. Automatic ban
2. Private
3. Opened

## Automatic BAN

This is the default mode, which is roughly like _fail2ban_. In this mode, new connections are limited below a certain
threshold, for instance, ten new connection attempts per minute. Above this threshold, IP addresses are automatically
banned, for instance for one hour.

Once a connection is established as valid, the source IP address is whitelisted, for instance for one hour, or more,
according to your configuration.

This mode is normally efficient enough to block most internet bots trying brute force attacks, on SSH, but also on other
ports like email submission(s) (resp. ports 587 and 465).

Default settings:

```yml
security:
  [...]
  autoban:
    active: true
    rate: 10/minute
    period: 2h
  trusted:
    period: 2h
```
