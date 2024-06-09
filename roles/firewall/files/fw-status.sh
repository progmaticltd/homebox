#!/bin/sh
#
## Simple script to display the current banned IP addresses in the firewall
##

banned_ipv4=$(nft -j list set inet filter banned_ipv4 | jq '[.nftables[1].set.elem[]]' 2>/dev/null)
banned_ipv6=$(nft -j list set inet filter banned_ipv6 | jq '[.nftables[1].set.elem[]]' 2>/dev/null)
trusted_ipv4=$(nft -j list set inet filter trusted_ipv4 | jq '[.nftables[1].set.elem[]]' 2>/dev/null)
trusted_ipv6=$(nft -j list set inet filter trusted_ipv6 | jq '[.nftables[1].set.elem[]]' 2>/dev/null)

banned_ipv4_count=$(echo "$banned_ipv4" | jq '. | length')
banned_ipv6_count=$(echo "$banned_ipv6" | jq '. | length')

trusted_ipv4_count=$(echo "$trusted_ipv4" | jq '. | length')
trusted_ipv6_count=$(echo "$trusted_ipv6" | jq '. | length')

if [ "$trusted_ipv4_count" != "" ]; then
    trusted_ipv4_list=$(echo "$trusted_ipv4" | jq '[.[].elem.val.concat[0]] | unique | .[]')
    trusted_ipv4_list=$(echo "$trusted_ipv4_list" | sed -E 's/"([^"]+)"/\1/g')
fi
if [ "$trusted_ipv6_count" != "" ]; then
    trusted_ipv6_list=$(echo "$trusted_ipv6" | jq '[.[].elem.val.concat[0]] | unique | .[]')
    trusted_ipv6_list=$(echo "$trusted_ipv6_list" | sed -E 's/"([^"]+)"/\1/g')
fi

# Filter by port
banned_ssh_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 22)]')
banned_ssh_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 22)]')
banned_imap_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 143)]')
banned_imap_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 143)]')
banned_imaps_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 993)]')
banned_imaps_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 993)]')
banned_pop3_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 110)]')
banned_pop3_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 110)]')
banned_pop3s_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 995)]')
banned_pop3s_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 995)]')
banned_submission_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 587)]')
banned_submission_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 587)]')
banned_submissions_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 465)]')
banned_submissions_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 465)]')
banned_xmpp_client_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 5222)]')
banned_xmpp_client_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 5222)]')
banned_xmpp_server_ipv4=$(echo "$banned_ipv4" | jq '[.[] | select(.elem.val.concat[1] == 5269)]')
banned_xmpp_server_ipv6=$(echo "$banned_ipv6" | jq '[.[] | select(.elem.val.concat[1] == 5269)]')


banned_ssh_ipv4_count=$(echo "$banned_ssh_ipv4" | jq '. | length')
banned_ssh_ipv6_count=$(echo "$banned_ssh_ipv6" | jq '. | length')
banned_imap_ipv4_count=$(echo "$banned_imap_ipv4" | jq '. | length')
banned_imap_ipv6_count=$(echo "$banned_imap_ipv6" | jq '. | length')
banned_imaps_ipv4_count=$(echo "$banned_imaps_ipv4" | jq '. | length')
banned_imaps_ipv6_count=$(echo "$banned_imaps_ipv6" | jq '. | length')
banned_pop3_ipv4_count=$(echo "$banned_pop3_ipv4" | jq '. | length')
banned_pop3_ipv6_count=$(echo "$banned_pop3_ipv6" | jq '. | length')
banned_pop3s_ipv4_count=$(echo "$banned_pop3s_ipv4" | jq '. | length')
banned_pop3s_ipv6_count=$(echo "$banned_pop3s_ipv6" | jq '. | length')
banned_submission_ipv4_count=$(echo "$banned_submission_ipv4" | jq '. | length')
banned_submission_ipv6_count=$(echo "$banned_submission_ipv6" | jq '. | length')
banned_submissions_ipv4_count=$(echo "$banned_submissions_ipv4" | jq '. | length')
banned_submissions_ipv6_count=$(echo "$banned_submissions_ipv6" | jq '. | length')
banned_xmpp_server_ipv4_count=$(echo "$banned_xmpp_server_ipv4" | jq '. | length')
banned_xmpp_server_ipv6_count=$(echo "$banned_xmpp_server_ipv6" | jq '. | length')
banned_xmpp_client_ipv4_count=$(echo "$banned_xmpp_client_ipv4" | jq '. | length')
banned_xmpp_client_ipv6_count=$(echo "$banned_xmpp_client_ipv6" | jq '. | length')


# List the details of bannip IP addresses
printf 'Banned IP addresses:\n\n' | colorize default --attr=bold
{
    echo '------------- | ----- | -----'
    printf 'SSH | %3d | %3d \n' "$banned_ssh_ipv4_count" "$banned_ssh_ipv6_count"
    printf 'IMAP | %3d | %3d \n' "$banned_imap_ipv4_count" "$banned_imap_ipv6_count"
    printf 'IMAPS | %3d | %3d \n' "$banned_imaps_ipv4_count" "$banned_imaps_ipv6_count"
    printf 'POP3 | %3d | %3d \n' "$banned_pop3_ipv4_count" "$banned_pop3_ipv6_count"
    printf 'POP3S | %3d | %3d \n' "$banned_pop3s_ipv4_count" "$banned_pop3s_ipv6_count"
    printf 'Submission | %3d | %3d \n' "$banned_submission_ipv4_count" "$banned_submission_ipv6_count"
    printf 'Submissions | %3d | %3d \n' "$banned_submissions_ipv4_count" "$banned_submissions_ipv6_count"
    printf 'XMPP (c2s) | %3d | %3d \n' "$banned_xmpp_client_ipv4_count" "$banned_xmpp_client_ipv6_count"
    printf 'XMPP (s2s) | %3d | %3d \n' "$banned_xmpp_server_ipv4_count" "$banned_xmpp_server_ipv6_count"
    echo '------------- | ----- | -----'
    printf 'Total | %3d | %3d \n' "$banned_ipv4_count" "$banned_ipv6_count"
} | column -t -s '|' -o ' | ' -N 'Protocol,IPv4,IPv6'

# List trusted IPs
printf '\n\nTrusted IPs\n\n' | colorize default --attr=bold
{
    echo '-- | --'
    for ip in $trusted_ipv4_list $trusted_ipv6_list; do
        descr=$(whois "$ip" | sed -En 's/descr:\s*(.*)/\1/p' | head -n 1)
        printf '%s|%s\n' "$ip" "$descr"
    done
} | column -t -s '|' -o ' | ' -N 'IP address,Whois details'


# List banned XMPP servers
banned_xmpp_servers=$((banned_xmpp_server_ipv4_count + banned_xmpp_server_ipv6_count))

if [ "$banned_xmpp_servers" -gt 0 ]; then

    banned_xmpp_server_ipv4_list=$(echo "$banned_xmpp_server_ipv4" | jq '[.[].elem.val.concat[0]] | unique | .[]')
    banned_xmpp_server_ipv4_list=$(echo "$banned_xmpp_server_ipv4_list" | sed -E 's/"([^"]+)"/\1/g')

    banned_xmpp_server_ipv6_list=$(echo "$banned_xmpp_server_ipv6" | jq '[.[].elem.val.concat[0]] | unique | .[]')
    banned_xmpp_server_ipv6_list=$(echo "$banned_xmpp_server_ipv6_list" | sed -E 's/"([^"]+)"/\1/g')

    printf '\n\nBanned XMPP serverss\n\n' | colorize default --attr=bold
    {
	echo '-- | --'
	for ip in $banned_xmpp_server_ipv4_list $banned_xmpp_server_ipv6_list; do
            descr=$(whois "$ip" | sed -En 's/Organization:\s*(.*)/\1/p' | head -n 1)
            printf '%s|%s\n' "$ip" "$descr"
	done
    } | column -t -s '|' -o ' | ' -N 'IP address,Whois details'

fi
