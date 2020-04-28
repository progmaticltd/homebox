# Default firewall configuration

```yaml
###############################################################################
# Once the system is in place, it is possible to use 'limit' for the rule,
# instead of allow. It is also possible to use fail2ban, which is installed anyway
# You can have as many sources as you want, with a comment to easily keep track
# of your rules
firewall:
  fwknop:
    install: false
    port: random
  ssh:
    - src: any
      rule: allow
      comment: allow SSH from anywhere
  output:
    policy: deny
    rules:
      - dest: any
        port: 80,443
        comment: 'Allow web access'
      - dest: any
        proto: udp
        port: 53
        comment: 'Allow DNS requests'
      - dest: any
        proto: udp
        port: 123
        comment: 'Allow NTP requests'
      - dest: any
        proto: udp
        from_port: 68
        port: 67
        comment: 'Allow DHCP requests'
      - dest: any
        port: 25
        comment: 'Allow SMTP connections to other servers'
      - dest: any
        port: 110,995,143,993
        comment: 'Allow the retrieval of emails from other servers (POP/IMAP)'
```


# Single Packet Authorization

This method of authorization is based around a default-drop packet filter and libpcap. SPA is essentially next
generation port knocking.

The fwknop client runs on Linux, Mac OS X, \*BSD, and Windows.  In addition, there is a port of the client to both the
iPhone and Android phones.

- Supports HMAC authenticated encryption for both Rijndael and GnuPG. The order of operation is
  encrypt-then-authenticate to avoid various cryptanalytic problems.
- Replay attacks are detected and thwarted by SHA-256 digest comparison of valid incoming SPA packets. SHA-1 and MD5 are
  also supported, but SHA-256 is the default.
- SPA packets are passively sniffed from the wire via libpcap. The fwknop server can also acquire packet data from a
  file that is written to by a separate Ethernet sniffer (such as with "tcpdump -w <file\>"), or from the iptables ULOG
  pcap writer.
- For iptables firewalls, ACCEPT rules added by fwknop are added and deleted (after a configurable timeout) from custom
  iptables chains so that fwknop does not interfere with any existing iptables policy.

!!! Warning
    If you don’t know what you are doing, be very careful, because one mistake will cause your SSH gone for good and
    there will be no way to manage your server.


More features detailed on the [fwknop features page](https://www.cipherdyne.org/fwknop/docs/features.html).

## Configuration examples

Alow direct SSH access from the local network, use fwknop otherwise. Monitor only queries sent to port number 33001.

``` yaml hl_lines="3 4 5 6"
# Allow SSH only from the LAN, otherwise use fwknop
firewall:
  fwknop:
    install: true
    nic: enp3s0
    port: 33001
  ssh:
    - src: 192.168.42.0/24
      rule: allow
      comment: allow SSH from the LAN only
```

Only allow SSH access using fwknop.  Allow to send the query to a random port number, between 10000 and 65535 by
default.

``` yaml hl_lines="3 4 5"
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
    port: random
  ssh:
    - src: any
      rule: allow
      comment: allow SSH from anywhere
```

## Keys backup

When running the installation script, fwnkop credentials are stored in
your home folder, in a file named after your domain, like ~/.fwknop-main.<domain>.rc,
(e.g. ~/.fwknop-main.homebox.space.rc.)
A backup is copied in your installation backup folder, `fwknop/fwknoprc`.

Here is an example:

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

### On Linux

Accessing your server, from the LAN or outside is slighly different

From the LAN, you can specify local IP address, here 192.168.66.33,
and the remote IP address, 192.168.66.1. For instance:

```sh
fwknop -v --rc-file ~/.fwknop-homebox.space.rc -a 192.168.66.33 -n main.homebox.space -D 192.168.66.1
ssh 192.168.66.1
```

From outside, you can use the automatic IP address lookup of www.cipherdyne.org:

```sh
fwknop -v --rc-file ~/.fwknop-homebox.space.rc -R --wget-cmd /usr/bin/wget -n main.homebox.space
ssh main.homebox.space
```

### On Android

You can also ‘knock’ your server from Android, using the excellent
[fwknop2 package](https://play.google.com/store/apps/details?id=org.cipherdyne.fwknop2).

The configuration is simple, see the example: [android client example](img/fwknop/android-client.png)

## Advanced

### Automatically knocking your server before connecting

While you can do this with a script, it is nicer to use the SSH ProxyCommand integration.
For instance, you can use this configuration on your `~/.ssh/config`:

``` conf
Host homebox.space
  User root
  ProxyCommand sh -c "fwknop -R -D main.homebox.space --rc-file ~/.fwknop-homebox.space.rc -n main.homebox.space ; /bin/nc %h %p"
```

### Using the port knoker with Ansible

It is possible to use fwknop during the development phase.
In this case, you should use fwknop client to knock the server, before the SSH connection.

Hopefully, homebox comes with a fwknop connection plugin for Ansible, ready to use.
There are two modifications to make:

The host file, specify the fwknop parameters:
```yaml
all:
  hosts:
    homebox:
      ansible_host: homebox.example.home
      ansible_user: root
      ansible_port: 22
      # special parameters when using fwknop port knocking
      fwknop_src: 192.168.14.55   # or 'auto' when connecting to a remote host over the internet.
      fwknop_config_name: main.example.home
      fwknop_dest: main.example.home
      fwknop_rc_file: /home/andre/.fwknop-example.home.rc
      fwknop_verbose: true
```
See the file `config/hosts-fwknop-example.yml` for a complete list of possible options.

Then, when running ansible, use the `-c` parameter to specify the connection method, and use ‘ssh_fwknop’.
The source code is in `common/connection_plugins`.

```sh
ansible-playbook -c ssh_fwknop -vvv -i ../config/hosts.yml playbooks/fwknop-server.yml
```

With the following output, for instance:

```sh
$ ansible-playbook -c ssh_fwknop -vvv -i ../config/hosts.yml playbooks/fwknop-server.yml
ansible-playbook 2.6.3
  config file = /home/andre/Projects/homebox/install/ansible.cfg
  configured module search path = [u'/home/andre/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 2.7.13 (default, Sep 26 2018, 18:42:22) [GCC 6.3.0 20170516]
Using /home/andre/Projects/homebox/install/ansible.cfg as config file
Parsed /home/andre/Projects/homebox/config/hosts.yml inventory source with yaml plugin
Read vars_file '{{ playbook_dir }}/../../config/system.yml'
Read vars_file '{{ playbook_dir }}/../../config/defaults.yml'

PLAYBOOK: fwknop-server.yml ********************************
1 plays in playbooks/fwknop-server.yml
Read vars_file '{{ playbook_dir }}/../../config/system.yml'
Read vars_file '{{ playbook_dir }}/../../config/defaults.yml'

PLAY [homebox] *********************************************
Read vars_file '{{ playbook_dir }}/../../config/system.yml'
Read vars_file '{{ playbook_dir }}/../../config/defaults.yml'

TASK [Gathering Facts] *************************************
task path: /home/andre/Projects/homebox/install/playbooks/fwknop-server.yml:4
<192.168.63.100> ssh_fwknop connection plugin is used for this host
Running '/usr/bin/fwknop -v -a 192.168.64.55 -D main.homebox.space --rc-file /home/andre/.fwknop-homebox.space.rc -n main.homebox.space
SPA Field Values:
=================
   Random Value: 4839788853776469
       Username: andre
      Timestamp: 1540127737
    FKO Version: 3.0.0
   Message Type: 1 (Access msg)
 Message String: 192.168.64.55,tcp/22
     Nat Access: <NULL>
    Server Auth: <NULL>
 Client Timeout: 0
    Digest Type: 3 (SHA256)
      HMAC Type: 3 (SHA256)
Encryption Type: 1 (Rijndael)
Encryption Mode: 2 (CBC)
...

```
