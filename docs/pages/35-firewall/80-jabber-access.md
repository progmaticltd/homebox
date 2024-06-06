# Jabber access

Like email access, Jabber access is protected by the nftables firewall, using the same
automatic ban approach.

Again, this will reduce the noise from the connection attempts, but will not get the rid
of internet bots and script kiddies.

This page describe three different variants for the firewall rules deployed to protect
the jabber servers, for both the _client to server_ communication, i.e. your users, and
for the _server to server_ communication, i.e. the other domains you are connecting to
using the XMPP protocol, if this option is activated.

For the two protocols, three modes are possible:

- autoban: authentication accepted, but an automatic ban from offender IPs, is set. This
  is the default.
- semi-private: authentication to the server is only allowed from trusted networks, and
  server-to-server connections are rate limited.
- private: both the authentication to the server and server-to-server communications are
  restricted to trusted networks.
- public: no protection, only use this if you know what you are doing.

You can see the corresponding firewall rules in the file
`roles/ejabberd/templates/nftables/`.

!!! Note
    Automatic ban is particularly well suited for a protocol like XMPP, as the TCP
    connection is normally kept open by the client for a longer period than email
    protocols. However, if you have special needs, for instance if your users have bad
    network connections, the rules can be more relaxed.


## Automatic ban for both

```yml
ejabberd:
  […]
  protection:
    c2s: autoban        # client to servers connections
    s2s: autoban        # server to servers connections

  autoban:
    rate: 5/hour        # above this rate, connections are dropped
    period: 4h          # period for banning IPs
```

In this example:

- Authentication attempts to the server are limited to five per hour.
- Connections from other Jabber servers are opened, but rate limited the same way.


## Semi private mode

This is probably perfect if all your users are behind the server's VPN, but you still want
them to send and receive message with other Jabber servers:

```yml
ejabberd:
  […]
  protection:
    c2s: private        # client to servers connections
    s2s: autoban        # server to servers connections

  autoban:
    rate: 5/hour        # above this rate, connections are dropped
    period: 4h          # period for banning IPs
```

- Authentication is only accepted from trusted trusted networks.
- Server to server connections are accepted but rate limited.


## Full private mode

This make sense if all your users are behind the server's VPN, _and_ you don't want to
establish connections with other Jabber servers _or_you restrict them to a few other
servers you trust.

As you can imagine, this is very restricted, but can be appropriate for communities with
privacy in mind.

```yml
ejabberd:
  […]
  protection:
    c2s: private        # client to servers connections
    s2s: private        # server to servers connections

  autoban:
    rate: 5/hour        # above this rate, connections are dropped
    period: 4h          # period for banning IPs
```


## Public access

```yml
ejabberd:
  […]
  protection:
    c2s: public         # client to servers connections
    s2s: public         # server to servers connections
```

This mode is probably for testing, or enough if you are using another IP address banning
solution, like fail2ban. In this mode, all the Jabber ports are opened without
restriction.
