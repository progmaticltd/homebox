#!/bin/sh -e
#
## Small utility to trust or ban an IP address
## Usage:
##   fw-control <ban|unban|trust|untrust|clear|check> <ip> [ports] [timeout]
##   - ban:     Ban an IP address and close any active connection from this address.
##              Use the default timeout if not specified.
##   - unban:   Unban an IP address; use "all" to flush banned IPs.
##   - trust:   Trust an IP address with the timeout specified or the default value.
##   - untrust: Untrust an IP address and close any active connection from this address.
##              Use "all" to flush trusted IPs
##   - clear:   Remove an IP address from all the tables
##   - check:   Check if an IP address is banned or trusted
##
## When not specified, the ports are taken from the running services
##
## When specified, the timeout should be a number with a suffix:
##   - seconds: s
##   - minutes: m
##   - minutes: h
##   - days:    d
##
## Examples:
##   - fw-control ban 87.144.5.74 465,587 1d
##   - fw-control ban 2a06:4880:5000::4f 25,465,587 4h
##   - fw-control trust 2a6.14.46.83 5222,5223 30m
##   - fw-control unban 112.34.19.78
##   - fw-control check 97.124.56.78
##   - fw-control clear 97.124.56.78
##   - fw-control unban all
##   - fw-control untrust all
#

# Exit codes
SUCCESS=0
ARG_ERROR=10
RUN_ERROR=10

# Default ports to ban or unban: email and jabber services only
default_ban_ports="110 995 143 993 465 587 4190 5222 5223"

# Default ports to check or clear: all the ports for public services
default_check_ports="22 80 443 110 995 143 993 465 587 4190 5222 5223 5269"

usage() {
    sed -En 's/^## //p' "$0"
}

action="$1"
ip="$2"
ports="$3"
timeout="$4"

if [ "$action" = "-h" ] || [ "$action" = "--help" ]; then
    usage
    exit
elif [ -z "$action" ] || [ -z "$ip" ]; then
    usage
    exit $ARG_ERROR
fi

# Detect and validate IP address type
ip_type=""

if [ "$ip" = "all" ]; then
    action="${action}-all"
elif ipcalc-ng -s -4 -c "$ip"; then
    ip_type="ipv4"
elif ipcalc-ng -s -6 -c "$ip"; then
    ip_type="ipv6"
else
    echo "Cannot parse IP address '$ip'" | colorize red 1>&2
    usage
    exit $ARG_ERROR
fi

# Detect and validate ports list
if [ -z "$ports" ] && [ "$action" != "check" ]; then
    ports="$default_ban_ports"
elif [ -z "$ports" ] && [ "$action" = "check" ]; then
    ports="$default_check_ports"
elif ! expr "$ports" : "^[0-9,]\+$" >/dev/null 2>&1; then
    echo "Cannot parse ports '$ports'" | colorize red 1>&2
    usage
    exit $ARG_ERROR
else
    ports=$(echo "$ports" | tr "," " ")
fi

# Detect and validate timeout value
if [ -n "$timeout" ] && ! expr "$timeout" : "^[0-9]\+[smhd]$" >/dev/null 2>&1; then
    echo "Cannot parse timeout '$timeout'" | colorize red 1>&2
    usage
    exit $ARG_ERROR
fi

# Update banned or trusted table with IP address, ports and timeout if specified
flush_set() {

    local table="$1"

    nft flush set inet filter "${table}_ipv4"
    nft flush set inet filter "${table}_ipv6"
}


# Update banned or trusted table with IP address, ports and timeout if specified
update_set() {

    local table="$1"
    local command="$2"
    local ip="$3"
    local ip_type="$4"
    local ports="$5"
    local timeout="$6"

    for port in $ports; do

        if [ -n "$timeout" ]; then
            ip_spec="{ $ip . $port timeout $timeout }"
        else
            ip_spec="{ $ip . $port }"
        fi

        list="${table}_${ip_type}"

        if [ "$command" = "add" ]; then

            # If the element is already present, remove it first.
            # This will update the timeout
            if nft get element inet filter "$list" "{ $ip . $port }" >/dev/null 2>&1; then
                nft delete element inet filter "$list" "{ $ip . $port }"
            fi

            # Then, add the element with the new timeout
            if ! nft add element inet filter "$list" "$ip_spec" >/dev/null 2>&1; then
                echo "Cannot add element '$ip_spec' from '$list'" | colorize red
                exit $RUN_ERROR
            fi

        elif [ "$command" = "delete" ]; then

            # Only delete if it is already present
            if nft get element inet filter "${list}" "$ip_spec" >/dev/null 2>&1; then

                if nft delete element inet filter "$list" "$ip_spec"; then
                    echo "Deleted element '{ $ip . $port }' from '$list'"
                else
                    echo "Cannot delete element '{ $ip . $port }' from '$list'" | colorize red
                    exit $RUN_ERROR
                fi
            fi
        fi

    done

}

# Close active connections when untrusting or banning IP addresses
close_connections() {

    local ip="$1"

    active_connections=$(conntrack -L --src "$ip" 2>/dev/null | wc -l)

    if [ "$active_connections" != "0" ]; then
        echo "Closing $active_connections active connections..."
        conntrack --delete --src "$ip" >/dev/null 2>&1
    fi
}

# Search for an IP address (IPv4 or IPv6) in the banned and trusted tables
search_ip() {

    local ip="$1"
    local ip_type="$2"
    local ports="$3"

    for list in trusted banned; do

        printf "Searching in %s_%s: " "$list" "$ip_type" | colorize default --attr=bold

        found="0"

        for port in $ports; do

            expires=$(nft get element inet filter "${list}_${ip_type}" "{ $ip . $port }" 2>&1 \
                          | sed -En 's/.*(expires .*) .*/\1/p' | sed -E 's/([dhms]s?)/\1 /g')

            if [ "$expires" != "" ]; then
                printf "\n- %-5d: %s" "$port" "$expires"
                found=$((found+1))
            fi

        done

        if [ "$found" = "0" ]; then
            echo "Not found." | colorize default --attr=bold
        else
            echo "\nFound $found time(s)." | colorize default --attr=bold
        fi

    done
}

case "$action" in

    check)
        search_ip "$ip" "$ip_type" "$ports"
        break
        ;;

    clear)
        update_set banned delete "$ip" "$ip_type" "$ports"
        update_set trusted delete "$ip" "$ip_type" "$ports"
        close_connections "$ip"
        break
        ;;

    untrust)
        update_set trusted delete "$ip" "$ip_type" "$ports"
        close_connections "$ip"
        break
        ;;

    trust)
        update_set banned delete "$ip" "$ip_type" "$ports"
        update_set trusted add "$ip" "$ip_type" "$ports" "$timeout"
        break
        ;;

    ban)
        update_set banned add "$ip" "$ip_type" "$ports" "$timeout"
        close_connections "$ip"
        break
        ;;

    unban)
        update_set banned delete "$ip" "$ip_type" "$ports"
        break
        ;;

    unban-all)
        flush_set banned
        break
        ;;

    untrust-all)
        flush_set trusted
        break
        ;;

    *)
        echo "Unknown action '$action'" | colorize red 1>&2
        usage
        exit $ARG_ERROR
esac
