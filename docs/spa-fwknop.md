# Single Packet Authorization with fwknop

This method of authorization is based around a default-drop packet
filter and libpcap. SPA is essentially next generation port
knocking.

The fwknop client runs on Linux, Mac OS X, *BSD, and Windows.
In addition, there is a port of the client to both the iPhone and Android phones.

- Supports HMAC authenticated encryption for both Rijndael and
  GnuPG. The order of operation is encrypt-then-authenticate to avoid
  various cryptanalytic problems.
- Replay attacks are detected and thwarted by SHA-256 digest
  comparison of valid incoming SPA packets. SHA-1 and MD5 are also
  supported, but SHA-256 is the default.
- SPA packets are passively sniffed from the wire via libpcap. The
  fwknop server can also acquire packet data from a file that is
  written to by a separate Ethernet sniffer (such as with "tcpdump -w
  <file>"), or from the iptables ULOG pcap writer.
- For iptables firewalls, ACCEPT rules added by fwknop are added and
  deleted (after a configurable timeout) from custom iptables chains
  so that fwknop does not interfere with any existing iptables policy.


More features detailed on the
[fwknop features page](https://www.cipherdyne.org/fwknop/docs/features.html).

## Configuration

### Configuration examples

Alow direct SSH access from the local network, use fwknop otherwise.

```yaml

# Allow SSH only from the LAN, otherwise use fwknop
firewall:
  fwknop:
    install: true
    nic: enp3s0
  ssh:
    - src: 192.168.42.0/24
      rule: allow
      comment: allow SSH from the LAN only
```

Only allow SSH access using fwknop

```yaml

# Allow SSH only from the LAN, otherwise use spa fwknopd
firewall:
  fwknop:
    install: true
    nic: eth0
  ssh:
    - src: any
      rule: deny
      comment: Do not allow SSH access except with fwknop
```

### Default configuration

```yaml

firewall_default:
  fwknop:
    install: false
    nic: '{{ ansible_default_ipv4.interface }}'
  ssh:
    - src: any
      rule: allow
      comment: allow SSH from anywhere
```

## Keys backup

When running the installation script, fwnkop credentials are stored in
your home folder, in a file named after your domain, like ~/.fknop-main.<domain>.rc,
(e.g. ~/.fknop-main.homebox.space.rc.)
A backup is copied in your installation backup folder, `fwknop/fwknoprc`.

Here an example:

```ini

[default]

[main.homebox.space]
ACCESS                      tcp/22
SPA_SERVER                  main.homebox.space
KEY_BASE64                  TD/Tudvg9IIdS8DYAxDFYYqL6qlRR7N0F7PSWb6QSqo=
HMAC_KEY_BASE64             mf1D7dIf2mMqgvnmeB8EosVDIEMlbHqJ1oKnW4TMmVWh4G7LHBbNzkBDvI+vw3f7TtdJYkYEjpc3JrHgA0QXYw==
USE_HMAC                    Y

```

## Knocking your server

Accessing your server, from the LAN or outside is slighly different

From the LAN, you can specify local IP address, here 192.168.66.33,
and the remote IP address, 192.168.66.1. For instance:

```sh
fwknop -v -a 192.168.66.33 -n main.homebox.space -D 192.168.66.1 ; ssh 192.168.66.1
```

From outside, you can use the automatic IP address lookup of www.cipherdyne.org:

```sh
fwknop -v -R --wget-cmd /usr/bin/wget -n main.homebox.space ; ssh main.homebox.space
```
