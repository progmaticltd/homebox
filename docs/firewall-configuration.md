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

