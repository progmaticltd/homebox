# Wireguard VPN

## Configuration

Configuring the Wireguard VPN is extremely easy, keys are created automatically, for the server and each users, from a
simple configuration setting in the system.yml file. The default configuration id displayed below:

```yml
# Default variables
wireguard:
  firewall:
    type: basic
  network:
    ipv4_address: 10.10.1.0/24
    ipv6_address: fdde:cade:2020:deaf::/64
    port: 51820
    ipv4_incr: 10
    ipv6_incr: 16
  # Send "keeps alive" packets at this interval.
  keep_alive: 15
  # By default, reates two configs for each user.
  configs:
    - name: default
      type: basic
    - name: mobile
      type: enforce
```

### Configuration types

In the example above, two configurations are created, called _default_ and _mobile_. Configuration types are explained
below:

#### Basic configuration

Basic configuration, only establish the connection, but does not enforce the traffic from the client to go through the
VPN. This is useful, for instance to connect on a server that only accept SSH connections from a VPN IP address.

#### Enforced traffic

All the traffic from the client is passing through the VPN server. DNS servers are pushed as well.

### Client IPs settings

You probably don't need to change these settings, unless you have loads of users to manage. The IP addresses for each
user are configured automatically, and cannot be changed without regenerating the keys.

- ipv4_address: IPv4 network address, as a CIDR. The server will get the first IP, the client the other IPs.
- ipv6_address: IPv6 network address, as a CIDR. The server will get the first IP, the client the other IPs.

The IP increment fields _ipv4_incr_ and _ipv4_incr_, are defining the final IPs for each user. Here the default
settings:

| Node               | IPv4        | IPv6                     |
|--------------------|-------------|--------------------------|
| Server             | 10.10.1.1   | fdde:cade:2020:deaf::1   |
| User 1 - config 1  | 10.10.1.10  | fdde:cade:2020:deaf::10  |
| User 1 - config 2  | 10.10.1.11  | fdde:cade:2020:deaf::11  |
| User 2 - config 1  | 10.10.1.20  | fdde:cade:2020:deaf::20  |
| User 2 - config 2  | 10.10.1.21  | fdde:cade:2020:deaf::21  |
| User 3 - config 1  | 10.10.1.30  | fdde:cade:2020:deaf::30  |
| User 3 - config 2  | 10.10.1.31  | fdde:cade:2020:deaf::31  |
| ...                | ...         | ...                      |
| User 25 - config 1 | 10.10.1.250 | fdde:cade:2020:deaf::250 |
| User 25 - config 2 | 10.10.1.251 | fdde:cade:2020:deaf::251 |
| User 25 - config 3 | 10.10.1.252 | fdde:cade:2020:deaf::252 |
| User 25 - config 4 | 10.10.1.253 | fdde:cade:2020:deaf::253 |
| User 25 - config 5 | 10.10.1.254 | fdde:cade:2020:deaf::254 |

By using an increment of 10 of IPv4 and 16 for IPv6, the IPs are logic, easy to understand. With these settings, the
maximum number of configuration per user is 10 for 24 users maximum, or 5 for 25 users. This should be perfectly enough
for a small group or a family.

If you want more users, or more configurations, you will likely need to change the IPv4 CIDR to a bigger value, for
instance, /16. You can also reduce the increment, let's say 5 instead of 10, and double the maximum number of users
to 40.

## Server installation

As usual, the deployment is using the same command:

```sh
ROLE=vpn-wireguard apb install.yml
```

## Server keys backup and restore

### Keys backup

```sh
ROLE=vpn-wireguard apb backup.yml
```

This will backup the keys in the _backup directory_ or into _pass_, according to your configuration.

### Keys restoration

```sh
ROLE=vpn-wireguard apb restore.yml
```

This will restore the keys from the _backup directory_ or from _pass_, according to your configuration.

## Server removal

As usual, the deployment is using the same command:

```sh
ROLE=vpn-wireguard apb uninstall.yml
```

Once removed, you can still re-install, and redeploy the same keys previously backed-up, using the following command:

```sh
ROLE=vpn-wireguard apb install.yml restore.yml
```
