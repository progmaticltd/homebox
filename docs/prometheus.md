## Prometheus monitoring

Prometheus and the alert manager can be automatically installed and configured.

Default settings:

```yml
prometheus:
  install: false
  memory:
    alert: 80
  swap:
    alert: 80
  system_load:
    alert: 80
  global:
    xmpp:
      recipient: '{{ users[0].mail }}'
    mail:
      recipient: '{{ users[0].mail }}'
```

You can override any field without having to redefine the entire structure.

### Services monitored

All the installed systemd services are monitored using the node-exporter systemd service monitor.

Some services are exporting specific metrics, like PowerDNS and Postfix.
