#!/bin/sh
#
## usage:
##   fail2ban-nft-helper <action> [-v] -j <name> [-i ip]
##
## examples:
##   fail2ban-nft-helper start -j postfix
##   start the postfix jail
##
##   fail2ban-nft-helper stop -j postfix
##   stop the postfix jail
##
##   fail2ban-nft-helper ban -j postfix -i 185.53.12.41
##   ban the IP address 185.53.12.41 in the postfix jail
#

# status and error codes
EXIT_SUCCESS=0
EXIT_ARG_ERROR=10
EXIT_IP_ERROR=20
EXIT_TABLE_ERROR=30

usage() {
    sed -n 's/^## //p' "$0"
}

if [ -z "$1" ]; then
    usage
    exit $EXIT_ARG_ERROR
fi

# First, read the action parameter
action=$(echo "$1" | sed -En 's/^(start|stop|ban|unban|check)$/\1/p')

if [ -z "$action" ]; then
    usage
    exit $EXIT_ARG_ERROR
else
    shift
fi

# Default values when not specified
name=""
ip=""
verbose="0"

while getopts 'j:i:v' opt; do
    case "$opt" in
        (j)
            # The jail name is always required
            name=$(echo "$OPTARG" | sed 's/[^a-z-]*//g')
            test -z "$name" && exit $EXIT_ARG_ERROR
            ;;
        (i)
            ipcalc-ng -s -c "$OPTARG" || exit $EXIT_ARG_ERROR
            ip="$OPTARG"
            ;;
        (v)
            verbose=1
            shift
            ;;
        (*)
            echo "Invalid argument '$opt'"
            exit $EXIT_ARG_ERROR
        ;;
    esac
done


if [ -z "$name" ]; then
    echo "Please, specify the jail name"
    exit $EXIT_ARG_ERROR
fi

# Display messages or not, depending the verbose flag
if [ "$verbose" = "0" ]; then
    message() {
        return
    }
else
    message() {
        printf "%s\n" "$*" >&2;
    }
fi




# Create the fail2ban filter if not existing,
# with a priority of -10 to run just before filters
start_jail() {

    name="$1"

    message "Starting jail '$name'"

    nft "add chain inet filter fail2ban { type filter hook input priority -10 ; }"

    nft add set inet filter "f2b-${name}-ipv4" '{ type ipv4_addr ; }'
    nft add set inet filter "f2b-${name}-ipv6" '{ type ipv6_addr ; }'

    nft inet filter fail2ban ip saddr "@f2b-${name}-ipv4" counter reject
    nft inet filter fail2ban ip6 saddr "@f2b-${name}-ipv6" counter reject
}

# Remove references to a jail, then the jail itself
stop_jail() {

    name="$1"

    message "Stopping jail '$name'"

    ipv4_handle=$(nft -a list ruleset | sed -En "s/.*@f2b-${name}-ipv4.*handle ([0-9]+)/\\1/p")
    ipv6_handle=$(nft -a list ruleset | sed -En "s/.*@f2b-${name}-ipv6.*handle ([0-9]+)/\\1/p")

    if [ "$ipv4_handle" != "" ]; then
        nft delete rule inet filter fail2ban handle "$ipv4_handle"
    else
        message "$0: rule handle not found for '$name'."
    fi

    if [ "$ipv6_handle" != "" ]; then
        nft delete rule inet filter fail2ban handle "$ipv6_handle"
    else
        message "$0: rule handle not found for '$name'."
    fi

    # Then, delete the sets if they exists
    if ! nft list set inet filter "f2b-${name}-ipv4" >/dev/null; then
        message "Warning: set 'f2b-${name}-ipv4' doesn't exists, ignoring."
    else
        nft delete set inet filter "f2b-${name}-ipv4";
    fi

    if ! nft list set inet filter "f2b-${name}-ipv6" >/dev/null; then
        message "Warning: set 'f2b-${name}-ipv6' doesn't exists, ignoring."
    else
        nft delete set inet filter "f2b-${name}-ipv6";
    fi
}

check_jail() {

    name="$1"

    message "Checking jail '$name'"

    if nft list set inet filter "f2b-${name}-ipv4" >/dev/null 2>&1; then
        message " - IPv4 OK"
    else
        message " - IPv4 not found"
    fi

    if nft list set inet filter "f2b-${name}-ipv6" >/dev/null 2>&1; then
        message " - IPv6 OK"
    else
        message " - IPv6 not found"
    fi

}


ban() {

    name="$1"
    ip="$2"
    type=""

    if ipcalc-ng -4 -c "$ip"; then
        type="ipv4"
    elif ipcalc-ng -6 -c "$ip"; then
        type="ipv6"
    else
        message "IP address is not valid"
        exit $EXIT_IP_ERROR
    fi

    if nft add element inet filter "f2b-${name}-${type}" "{ $ip }"; then
        message "Banning ${type} '$ip' for jail '${name}': Success"
    else
        message "Banning ${type} '$ip' for jail '${name}': Error"
    fi

}

unban() {

    name="$1"
    ip="$2"
    type=""

    if ipcalc-ng -4 -c "$ip"; then
        type="ipv4"
    elif ipcalc-ng -6 -c "$ip"; then
        type="ipv6"
    else
        message "IP address is not valid"
        exit $EXIT_IP_ERROR
    fi

    if nft delete element inet filter "f2b-${name}-${type}" "{ $ip }"; then
        message "Unbanning ${type} '$ip' for jail '${name}': Success"
    else
        message "Unbanning ${type} '$ip' for jail '${name}': Error"
    fi

}

case "$action" in
    start)
        start_jail "$name"
        ;;
    stop)
        stop_jail "$name"
        ;;
    ban)
        ipcalc-ng -s -c "$ip" || exit $EXIT_ARG_ERROR
        ban "$name" "$ip"
        ;;
    unban)
        ipcalc-ng -s -c "$ip" || exit $EXIT_ARG_ERROR
        unban "$name" "$ip"
        ;;
    check)
        check_jail "$name"
        ;;
    *)
        exit $EXIT_ARG_ERROR
esac
