# Forwarded traffic

When installing the firewall, forwarded traffic is dropped by default.

```nftables
table inet filter {
    chain forward {
        type filter hook forward priority 0
        policy drop
    }
}
```

For now, there is only one role that adds rules into the forwarding tables, which is the
[Wireguard VPN server](/pages/40-wireguard-vpn/10-configuration/).
