# Tor and Privoxy

The _Onion Router_ Tor, can be installed, along with _Privoxy_, in a very simplistic configuration.
Privoxy is a free non-caching web proxy with filtering capabilities for enhancing privacy.

It provides a basic privacy protection, alongside wih some browsers extensions. More information on
this page: [https://restoreprivacy.com/firefox-privacy/](https://restoreprivacy.com/firefox-privacy/).

You may also want to select an alternative search engine like [DuckDuckGo](https://duckduckgo.com/).

## Default configuration

The configuration actually installed is the default one on Debian, but you can easily customise it
using the standard Tor or Privoxy options.

Tor is not accessible externally.
Privoxy is listening on port 8118, on the LAN by default.

Both are configured to run in AppArmor profile.


### Minimal configuration

```yaml

# Secure / Anonymous proxy
tor:
  install: true

privoxy:
  install: true

```

### Default configuration

```yaml

# The onion router
tor:
  install: false
  port: 9050
  accept_from:
    - 127.0.0.1

# Privoxy privacy proxy
privoxy:
  install: false
  port: 8118
  accept_from:
    - 10.0.0.0/8
    - 192.168.0.0/16
    - 172.16.0.0/20
  custom_settings: |
    # Put anything you want here,
    # even on multiple lines
```
