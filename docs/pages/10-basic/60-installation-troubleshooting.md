# Troubleshooting

If everything works correctly, you can jump to the next section, _after the installation_.

If something goes wrong, or if you want to see more details, use the following command to
run the installation in verbose mode:

```sh
cd playbooks
ansible-playbook -vv install-version.yml
```

## No password for root

If you see this:

```sh
fatal: [homebox]: FAILED! =>
  msg: Missing sudo password
```

You probably forgot to add the installation user to the sudo group. Check the section
[Prepare your target](/10-prepare-your-target/).


## PowerDNS fails to start

If you see something like this:

```sh
RUNNING HANDLER [dns-pdns : Restart PowerDNS] ******************************************************
fatal: [homebox]: FAILED! => changed=false
  msg: |-
    Unable to restart service pdns: Job for pdns.service failed because the control process exited with error code.
    See "systemctl status pdns.service" and "journalctl -xeu pdns.service" for details.

```

Check that the external IP addresses you have specified ar associated to a network
interface. If the server is reachable on internet through a public IP address, but only
has a LAN (i.e. a local / private) IP address, then use the `bind_ip` option in the
network settings. See the [configuration page](30-define-your-config.md).

If you are testing HomeBox in a virtual machine, make sure to assign both IP addresses to
the _loopback_ network interface. This procedure is also explained in the section
[IP addresses](../20-development/10-development-environment/#about-the-ip-addresses).


## Mailing lists

Thanks to [Framasoft](https://framasoft.org/), two mailing lists have been created, one
for general questions, suggestions and support, and another one dedicated for development.

- General questions: [homebox-general](https://framalistes.org/sympa/info/homebox-general).
- Development: [homebox-dev](https://framalistes.org/sympa/info/homebox-dev).
