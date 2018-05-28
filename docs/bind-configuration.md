# Default configuration

The default configuration for the DNS server comes with the following options:

- Not installed by default
- DNSSEC Not activated by default

Default options for the server:

```yaml

###############################################################################
# Bind server defaults
bind_default:
  # Bind is actually in testing phase, feedback welcome
  install: false
  # Default servers to forward queries
  forward:
    - 8.8.8.8
    - 8.8.4.4
    - 1.1.1.1
  # Actually, reverse IP address creation only works for IPv4
  # If you are using IPv6, create the reverse IP block here
  reverse_ip: auto
  # Timing configuration (see https://www.ripe.net/publications/docs/ripe-203)
  refresh: 86400          # 24 hours
  retry: 7200             # 2 hours
  expire: 3600000         # 10000 hours
  neg_cache_ttl: 172800   # 2 days
  ttl: 3600               # 1 hour
  # General configuration
  mx_priority: 10
  # List of trusted servers to accept cache / recursive queries
  trusted:
    - src: 192.168.0.0/16
      comment: LAN
    - src: localhost
    - src: localnets
      comment: Local networks
  #  - src: 72.13.58.64
  #    comment: https://dnssec-analyzer.verisignlabs.com
  # DNSSEC options
  dnssec:
    active: false
    algo: RSASHA256

```

## Options

### Servers to use for fowarding

By default, the Google public DNS servers are used, as well as the one from cloudflare.

More choice here: [Public DNS](https://en.wikipedia.org/wiki/Google_Public_DNS#See_also).

### Trusted servers

Enter the list of trusted servers for recursion and cache query.

### DNSSEC

DNSSEC is not activated by default. Be sure your domain name supports it before activating it.

More details on the [Wikipedia page](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions)
