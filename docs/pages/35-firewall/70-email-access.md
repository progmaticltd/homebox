# Email access

Unfortunately, as soon as your mail server is online, it will be a potential target for
spammers, script-kiddies, and sometimes determined and malevolent and more proficient
people.

Beside the noise from SSH connection attempts, you may find surprising amount of
authentication attempts on your mail server components, particularly on the _postfix_,
submission ports. Authentication is not activated on SMTP, but if you are activating the
debug options, you will see many attempts as well.

This page describe four different variants for the firewall rules deployed to protect
email sending (Submission/s) and email retrieving (IMAP(s), POP3(s) and MANAGESIEVE).

Before getting into the deeper details, here a summary of the four possible modes are:

- autoban: All email related ports are opened, but an automatic ban from offender IPs,
  like _fail2ban_ is set. This is the default.
- protected: Submission and communication ports are only opened _after_ a successful
  authentication from your mail client.
- private: connection to any email port is only allowed from trusted networks. Perfect
  when all your users are using the VPN.
- public: no protection, only use this if you know what you are doing.

For _Postfix_ and _Dovecot_, you can see the corresponding firewall rules in the roles

- `roles/postfix/templates/nftables/`.
- `roles/dovecot/templates/nftables/`.


## Automatic ban

```yml
mail_defaults:
  […]
  protection:
    type: autoban

  autoban:
    rate: 10/minute     # above this rate, connections are rejected
    period: 1h          # period for banning IPs
```

In this mode:

- Email retrieving ports are opened, but rate limited.
- Email submission ports are opened, but rate limited.

New connections are allowed on the submission ports (587 and 465), below a certain rate
described above. Above this rate, IP addresses are banned to access the Submission ports.

Note that if you are using an email client to send emails, you don't need to worry about
the rate limit of email sending; on successful IMAP/POP3 authentication, the source IP
address is automatically added to the `trusted_ipv4` or `trusted_ipv6`, and the rate limit
does not apply any more.

This is often enough for most common mail servers, but does not protect you enough from
more sophisticated attacks, like some brute force attacks from entire networks,
especially those using automatic throttling. The _protected_ or _private_ modes described
below are more efficient for this.


## Protected mode

In this mode:

- Email retrieving ports are opened, but rate limited.
- Email submission authentication ports are initially only opened for trusted IPs and
  trusted networks.

This mode can also be appropriate to the most common usage, and offer a higher protection
against brute force attacks. When sending emails, most users will start a mail client on
their desktop or their phone, write an email, and press the "Send" button.

Behind the scene, the source IP address are automatically added to the `trusted_ipv4` or
`trusted_ipv6` IP sets by the dovecot _post-login_ script, which then make sending emails
from the client totally transparent.

You can see below an example, of the IP address `33.128.11.12` automatically whitelisted
by Dovecot, in _nftables_:

```nftables
set trusted_ipv4 {
  type ipv4_addr . inet_service
  flags dynamic,timeout
  timeout 5h
  elements = { 33.128.11.12 . 587 timeout 1d expires 23h32m47s316ms,
               33.128.11.12 . 4190 timeout 1d expires 23h32m47s360ms,
               33.128.11.12 . 143 timeout 1d expires 23h32m47s196ms,
               33.128.11.12 . 465 timeout 1d expires 23h32m47s280ms,
               33.128.11.12 . 993 timeout 1d expires 23h32m47s248ms,
               33.128.11.12 . 995 timeout 1d expires 23h32m47s148ms }
        }
```

As we can see above, all the common ports related to emails have been whitelisted for one
day.

!!! Warning
    In this mode, if you want to send emails without using a mail client, for instance
    with a script or from a remote web site, there is one step to do: Just make sure to
    add the source IP addresses your script is running from, or the web site IP addresses,
    in the `trusted_networks_ipv4/6` lists.


## Private access

This mode is the safest:

- Email retrieving ports are only opened for trusted IPs and trusted networks.
- Email submission authentication ports are only opened for trusted IPs and trusted
  networks.

In this mode, authenticating against postfix or Dovecot can only be done from trusted IP
addresses. This is the safest option, and it is perfectly valid when you are using the
Wireguard VPN module.

Note that even if automatic IP whitelisting is not necessary in this case, dovecot still
add the IP addresses to the trusted lists, and your firewall rules would look like
something like this:

```nftables
set trusted_ipv4 {
  type ipv4_addr . inet_service
  flags dynamic,timeout
  timeout 5h
  elements = { 10.10.1.14 . 587 timeout 1d expires 23h32m47s316ms,
               10.10.1.14 . 4190 timeout 1d expires 23h32m47s360ms,
               10.10.1.14 . 143 timeout 1d expires 23h32m47s196ms,
               10.10.1.14 . 465 timeout 1d expires 23h32m47s280ms,
               10.10.1.14 . 993 timeout 1d expires 23h32m47s248ms,
               10.10.1.14 . 995 timeout 1d expires 23h32m47s148ms }
        }
```


## Public access

This mode is probably for testing, or enough if you are using another IP address banning
solution, like fail2ban. In this mode, all the email ports are opened without
restriction.
