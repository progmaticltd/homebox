# Firewall principles

The firewall is based on the modern [nftables](https://nftables.org/), and is filtering
the traffic on _input_, _output_ and _forwarding_ chains, on both IPv4 and IPv6 stacks.

When the deployment begins, the role `bootstrap` installs a minimal set of rules are installed
in `/etc/nftables` directory, included by default in the parent `/etc/nftables.conf` script:

```nftables
#!/usr/sbin/nft -f

# Include all other rules
include "/etc/nftables/*.nft"
```

The minimal set is:

- The inbound traffic is dropped, except SSH connections and minimal ICMP, for instance ping
  requests.
- The outbound traffic is rejected, except the one required to access Debian repositories.
- The forward traffic is dropped.
