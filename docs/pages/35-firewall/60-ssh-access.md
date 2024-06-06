# SSH access

By default, the SSH server is accessible publicly, so you can connect from any IP address:

The default security settings for the firewall, are defined in the file
`config/defaults/common-security.yml`, and the part we are talking is this one:

```yml
security_default:
  […]
  ssh:
    public: true
```

To limit the bot connections on your SSH server, there is an automatic IP address banning,
activated by default.

The _autoban_ mode is efficient enough to limit the efficiency and the noise of the most
common brute force attacks found on internet, especially on SSH servers.

```yml
security_default:
  […]
  autoban:
    active: true
    rate: 10/minute
    period: 2h
  trusted:
    period: 2h
```

You can copy the block, call it `security` and override the values you need, for instance,
you could copy the following block in your `system.yml` file:


```yml
security:
  […]
  autoban:
    rate: 5/minute
    period: 4h
  trusted:
    period: 4h
```

!!! Note
    When overriding values, remember to remove the `_default` suffix. You also don't need
    to redefine all the values, just rewrite the ones you are interested in. In the
    example above, the `active: true` has been removed, as it is the default.

The ban is done using _nftables_ dynamic sets.

## Automatic banning mode

Firewall default security settings in the file
`config/defaults/common-security.yml`, and can be copied to define your own.


```yml
security_default:
  […]
  autoban:
    active: true
    rate: 10/minute
    period: 2h
  trusted:
    period: 2h
```

This page explains in greater details the _autoban_ principles.

This is the default mode, which is roughly like _fail2ban_, but implemented using
_nftables_ dynamic sets. In this mode, new connections are limited below a certain
threshold, for instance, ten new connection attempts per minute. Above this threshold, IP
addresses are automatically banned, for instance for one hour.

This mode is normally efficient enough to block most internet bots trying brute force
attacks, on SSH, especially since the SSH server is not configured to accept password
authentication.


## Private mode

Private mode is a drastic but efficient answer to some extreme cases, especially when the
server is actively targeted by a determined attacker. It is also a good solution for a
community concerned by the security, especially when using the VPN, as we'll see below.

In this mode, SSH connections are only authorised from _tusted_ IP addresses, which will
be explained later.

```yml
security:
  ssh:
    public: false
```
