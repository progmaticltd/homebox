#!/bin/sh
#
## This script is automatically called by systemd networkd-dispatcher,
## when the wireguard interface is up and routable.
## It is adding the VPN network addresses to the trusted networks.
## After that, each role is responsible on how connections from these networks are handled.
## Unfortunately, the information received by systemd-networkd is missing the network mask,
## so it is computed here.
#

# Don't do anything unless called for wireguard
if [ "$IFACE" != "wg0" ]; then
        exit 0
fi

# VPN IP addresses
ip4_spec={{ wireguard.network.ipv4_address }}
ip6_spec={{ wireguard.network.ipv6_address }}

# Default timeout to whitelist
timeout="365d"


if [ "$OperationalState" = "routable" ]; then

    if nft add element inet filter trusted_networks_ipv4 "{ $ip4_spec timeout $timeout }"; then
        echo "Added $ip4_spec to trusted networks."
    else
        echo "Failed to add $ip4_spec to trusted networks."
    fi

    if nft add element inet filter trusted_networks_ipv6 "{ $ip6_spec timeout $timeout }"; then
        echo "Added $ip6_spec to trusted networks."
    else
        echo "Failed to add $ip6_spec to trusted networks."
    fi

elif [ "$OperationalState" = "off" ]; then

    if nft delete element inet filter trusted_networks_ipv4 "{ $ip4_spec }"; then
        echo "Removed $ip4_spec from trusted networks."
    else
        echo "Failed to remove $ip4_spec from trusted networks."
    fi

    if nft delete element inet filter trusted_networks_ipv6 "{ $ip6_spec }"; then
        echo "Removed $ip6_spec from trusted networks."
    else
        echo "Failed to remove $ip6_spec from trusted networks."
    fi

fi
