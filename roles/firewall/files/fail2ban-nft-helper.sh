#!/bin/sh
#
## Work in progress

action=$1

if [ "$action" = "start" ]; then

    name=$2

    # Create the fail2ban filter if not existing,
    # with a priority of -10 to run just before fitlers
    nft 'add chain inet filter fail2ban { type filter hook input priority -10 ; }'

    nft add set inet filter "f2b-${name}-ipv4" '{ type ipv4_addr ; }'
    nft add set inet filter "f2b-${name}-ipv6" '{ type ipv6_addr ; }'

    nft inet filter fail2ban ip saddr "@f2b-${name}-ipv4" counter reject
    nft inet filter fail2ban ip6 saddr "@f2b-${name}-ipv6" counter reject

    exit
fi

if [ "$action" = "stop" ]; then

    name=$2
    port=$3

    ipv4_handle=$(nft -a list ruleset | sed -En "s/.*@f2b-${name}-ipv4.*handle ([0-9]+)/\\1/p")
    ipv6_handle=$(nft -a list ruleset | sed -En "s/.*@f2b-${name}-ipv6.*handle ([0-9]+)/\\1/p")

    if [ "$ipv4_handle" != "" ]; then
        nft delete rule inet filter fail2ban handle "$ipv4_handle"
    elif [ "$ipv6_handle" != "" ]; then
        nft delete rule inet filter fail2ban handle "$ipv6_handle"
    else
        echo "$0: rule handle not found for '$name'."
    fi

    exit
fi

if [ "$action" = "check" ]; then

    name=$2
    port=$3

    nft list set inet filter "f2b-$name-ipv4"
    nft list set inet filter "f2b-$name-ipv6"

    exit
fi

if [ "$action" = "ban" ]; then

    name=$2
    ip=$3
    type=$4

    if echo "$ip" | grep -P '^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$'; then
        nft add element inet filter "f2b-$name-ipv4" "{ $ip }"
    else
        nft add element inet filter "f2b-$name-ipv6" "{ $ip }"
    fi

    exit
fi

if [ "$action" = "unban" ]; then

    name=$2
    ip=$3
    type=$4

    if echo "$ip" | grep -P '^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$'; then
        nft delete element inet filter "f2b-$name-ipv4" "{ $ip }"
    else
        nft delete element inet filter "f2b-$name-ipv6" "{ $ip }"
    fi

    exit
fi
