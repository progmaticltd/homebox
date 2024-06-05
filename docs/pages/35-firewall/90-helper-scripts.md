# Helper scripts

When the firewall basic rules are deployed, two scripts are installed in
`/usr/local/sbin`, for the system administrator, to see the firewall banned and trusted
list status.

## Firewall status

The script `fw-status` simply show a summary table of banned and trusted IP addresses,
more readable than the firewall raw rules:

```plain
root@voodoo ~# fw-status
Banned IP addresses:

Protocol       | IPv4    | IPv6
-------------  |  -----  |  -----
SSH            |  125    |   21
IMAP           |   26    |    3
IMAPS          |   46    |    1
POP3           |    0    |    0
POP3S          |   30    |    0
Submission     |    9    |    1
Submissions    |   36    |    4
XMPP (s2s)     |   42    |    0
-------------  |  -----  |  -----
Total          |  614    |    0


Trusted IPs

IP address                           | Whois details
--                                   |  --
45.63.101.247                        |
12.78.131.32                         | Pandora Box Internet Inc
2a02:8010:684b:0:21e4:de36:0c0b:afe5 | Pandora Box Internet
```

## Trusting or banning IP addresses

The next script, called `fw-control` allows you to trust, untrust, ban or unban any an IP
address, or to check the current banning status.

Without any argument, it will display the following help text:

```plain
root@pigment /etc/nftables# fw-control
Small utility to trust or ban an IP address

Usage:
  fw-control <ban|unban|trust|untrust|clear|check> <ip> [ports] [timeout]
  - ban:     Ban an IP address and close any active connection from this address.
             Use the default timeout if not specified.
  - unban:   Unban an IP address; use "all" to flush banned IPs.
  - trust:   Trust an IP address with the timeout specified or the default value.
  - untrust: Untrust an IP address and close any active connection from this address.
             Use "all" to flush trusted IPs
  - clear:   Remove an IP address from all the tables
  - check:   Check if an IP address is banned or trusted

When not specified, the ports are taken from the running services

When specified, the timeout should be a number with a suffix:
  - seconds: s
  - minutes: m
  - minutes: h
  - days:    d

Examples:
  - fw-control ban 87.144.5.74 465,587 1d
  - fw-control ban 2a06:4880:5000::4f 25,465,587 4h
  - fw-control trust 2a6.14.46.83 5222,5223 30m
  - fw-control unban 112.34.19.78
  - fw-control check 97.124.56.78
  - fw-control clear 97.124.56.78
  - fw-control unban all
  - fw-control untrust all
```

Example to check if an IP address is banned:

```plain
root@pandorat ~# fw-control check 167.94.138.39
Searching in trusted_ipv4: Not found.
Searching in banned_ipv4:
- 995  : expires  28d 15h 29m 56s 32ms
Found 1 time(s).
```

Example to trust an IP address:

```plain
root@pigment ~# fw-control trust 122.88.211.12 22
```

And removing the IP:

```plain
root@pigment ~# fw-control untrust 122.88.211.12 22
Deleted element '{ 122.88.211.12 . 22 }' from 'trusted_ipv4'
Closing 1 active connections...
```

!!! Note
    When "untrusting" an IP address, connections to this IP are terminated as well.
