# Trust and Ban

## Trusted and Banned networks

### Trusted networks

The firewall has two _sets_, empty by default, called `trusted_networks_ipv4`, and
`trusted_networks_ipv6`. As the name suggest, they hold respectively IPv4 and IPv6
networks, and a timeout.

You can manually or automatically, depending on your needs, add network addresses to these
sets, for instance, using the following command.

```sh
nft add element inet filter trusted_networks_ipv4 '{ 11.22.33.0/24 timeout 90d }'
```

The _timeout_ value is optional. When not specified, it will use the default value defined
in the initial set definition.


#### Coupling with VPN

Thankfully, there is a better option than managing the whitelisted network yourself.

When the [Wireguard VPN server](/pages/40-wireguard-vpn/10-configuration/) component is
installed, its network addresses are automatically added on startup. This makes the
whitelisting transparent for your users, as long as you are using a VPN server.


### Banned networks

Conversely to the trusted networks, there are two _sets_, empty by default, called
`banned_networks_ipv4`, and `banned_networks_ipv6`. As the name suggest, they hold
respectively IPv4 and IPv6 networks.

!!! Note
    In this case, however, any connection attempt from a banned network is silently
    dropped at the beginning of the firewall rules.


## Trusted and Banned IPs

Trusted and banned networks are practical to store entire networks, but are not used for
automatic banning or trusting on specific services.

There are two different sets, called `trusted_ipv4` or `trusted_ipv6`, storing IP
addresses, service port and a timeoout.

## Trusted IPs

```nftables
table inet filter {

    set trusted_ipv4 {
        type ipv4_addr . inet_service
        flags dynamic,timeout
        timeout {{ security.autoban.period }}
    }

    set trusted_ipv6 {
        type ipv6_addr . inet_service
        flags dynamic,timeout
        timeout {{ security.autoban.period }}
    }
}
```

## Banned IPs

```nftables
table inet filter {

    set banned_ipv4 {
        type ipv4_addr . inet_service
        flags dynamic,timeout
        timeout {{ security.autoban.period }}
    }

    set banned_ipv6 {
        type ipv6_addr . inet_service
        flags dynamic,timeout
        timeout {{ security.autoban.period }}
    }
}
```
