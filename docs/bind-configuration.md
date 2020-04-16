# Default configuration

The default configuration for the DNS server comes with the following options:

- Installed by default
- Forward to google and cloudflare DNS
- DNSSEC Not activated by default

Default options for the server:

```yaml
bind_default:
  # Bind is actually in testing phase, feedback welcome
  install: true
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
  # List of backup MX records, if the server is unreachable
  # The default is an empty list
  mx_backup: []
  # Example of records
  # mx_backup:
  #   - fqdn: spool.mail.gandi.net
  #     priority: 10
  #   - fqdn: fb.mail.gandi.net
  #     priority: 50
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

# Forwarding queries

By default, the Google public DNS servers are used, as well as the one from cloudflare.

More choices here: [Public DNS](https://en.wikipedia.org/wiki/Google_Public_DNS#See_also).

# Backup MX records

If your server is not online, for instance due to an internet outage, you can use this option to redirect emails
reception to another server. In this case, the other MTA should be configured to accept emails for your domain.

If you use this option, you will probably consider importing the emails delivered to these "backup servers", to your own
server, using the [external account](external-accounts.md) functionality.

# Trusted servers

Enter the list of trusted servers for recursion and cache query.

# DNSSEC extensions

DNSSEC is not activated by default. Be sure your domain name supports it before activating it.

More details on the [Wikipedia page](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions)
