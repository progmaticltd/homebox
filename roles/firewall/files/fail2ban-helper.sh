#!/bin/sh
#
## Work in progress

action=$1

if [ "$action" = "start" ]; then

    name=$2

    nft add set inet filter "f2b-${name}-ipv4" '{ type ipv4_addr ; }'
    nft add set inet filter "f2b-${name}-ipv6" '{ type ipv6_addr ; }'

    nft inet filter ban ip saddr "@f2b-${name}-ipv4" drop
    nft inet filter ban ip6 saddr "@f2b-${name}-ipv6" drop

    exit
fi

if [ "$action" = "stop" ]; then

    name=$2
    port=$3

    ipv4_handle=$(nft -a list ruleset | sed -En "s/.*@f2b-${name}-ipv4.*handle ([0-9]+)/\\1/p")

    if [ "$ipv4_handle" != "" ]; then
	nft delete rule inet filter ban handle "$ipv4_handle"
    else
	echo "$0: rule handle not found for IPv4: '$name'"
    fi

    ipv6_handle=$(nft -a list ruleset | sed -En "s/.*@f2b-${name}-ipv6.*handle ([0-9]+)/\\1/p")

    if [ "$ipv6_handle" != "" ]; then
	nft delete rule inet filter ban handle "$ipv6_handle"
    else
	echo "$0: rule handle not found for IPv6: '$name'"
    fi

    exit
fi

if [ "$action" = "check" ]; then
    exit
fi

if [ "$action" = "ban" ]; then

    name=$2
    ip=$3
    type=$4

    nft add element inet filter "f2b-$name-ipv4" "{ $ip }" || /bin/true
    nft add element inet filter "f2b-$name-ipv6" "{ $ip }" || /bin/true

    exit
fi

if [ "$action" = "unban" ]; then

    name=$2
    ip=$3
    type=$4

    nft delete element inet filter "f2b-$name-ipv4" "{ $ip }" || /bin/true
    nft delete element inet filter "f2b-$name-ipv6" "{ $ip }" || /bin/true

    exit
fi
