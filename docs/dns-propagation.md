Homebox includes with a DNS server with many security and convenient features.

# Minimal configuration

This is the minimal configuration for bind, but there are many options. See system-example.yml file.

```yaml
#  Bind server defaults
bind:
  install: true
  # Default servers to forward queries
  forward:
    - 8.8.8.8
    - 1.1.1.1
    - 2001:4860:4860::8888
    - 2001:4860:4860::8844
```

# Monitor world wide propagation

Sometimes, complete DNS Resolution may take upto 48 hours. For the second step, this can be monitored and checked on one
of these sites: [www.whatsmydns.net](https://www.whatsmydns.net/):

![DNS propagation finished](img/dns/dns-propagation-finished.png "DNS propagation finished")

Or [dnschecker.org](https://dnschecker.org).

Or from the command line:

_DNS not updated:_

```sh
root@homebox /etc/network# host main.hmbx.pw 1.1.1.1
Using domain server:
Name: 1.1.1.1
Address: 1.1.1.1#53
Aliases:

Host main.hmbx.pw not found: 2(SERVFAIL)
```

_DNS updated:_

```sh
root@homebox /etc/network# host main.rodier.me 1.1.1.1
Using domain server:
Name: 1.1.1.1
Address: 1.1.1.1#53
Aliases:

main.rodier.me has address 92.19.253.41
```

**It is only once the DNS propagation will be complate that you will be able to run your Ansible deployment scripts.**
