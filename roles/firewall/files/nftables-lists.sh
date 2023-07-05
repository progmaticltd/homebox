#!/bin/sh

# This file is called to save or load nftables dynamic rules

# List to load and save
lists="banned_ipv4 banned_ipv6 trusted_ipv4 trusted_ipv6"

flush_lists() {
    for list in $lists; do
        nft flush set inet filter "$list"
    done
}

save_lists() {

    test -d /var/lib/nftables/ || mkdir -m 0700 /var/lib/nftables/

    for list in $lists; do
        nft list set inet filter "$list" >"/var/lib/nftables/$list.nft"
    done
}

load_lists() {
    for list in $lists; do
        # The file should exists
        test -r "/var/lib/nftables/$list.nft" || continue

        if nft -c -f "/var/lib/nftables/$list.nft"; then
            nft -f "/var/lib/nftables/$list.nft"
        fi
    done
}

# Check if the lists exists or exit
for list in $lists; do
    if ! nft list set inet filter "$list" >/dev/null; then
        echo "Missing list $list: exit"
        exit
    fi
done


if [ "$1" = "save" ]; then
    save_lists
elif [ "$1" = "flush" ]; then
    flush_lists
elif [ "$1" = "load" ]; then
    load_lists
elif [ "$1" = "reload" ]; then
    flush_lists
    load_lists
fi
