# Define your system configuration

The configuration is stored into _Yaml_ files, a lightweight markup language often used by
Ansible.

- The important notion to keep in mind is _the indentation is important_, and _do not use
  tabs_.
- All the commands below should be run in the `homebox` folder, unless specified
  otherwise.

## 1. Choose your flavour

Initially, you'll have to choose a flavour to install, according to your system resources
and your tastes. A _flavour_ is a predefined set of features, or "components".

Note that it is possible to start with a small flavour, and dynamically add or remove
components later.  Some features are not included in any flavour, but can still be
installed or uninstalled.

There are four pre-configured settings you could use:

- Mini: mail server with only minimal settings, useful for systems with limited resources.
- Small: mail server only with extended options.
- Medium: mail and collaboration server.
- Large: mail, collaboration server and extraneous components.

| Feature                                 | Mini | Small | Medium | Large | Software                              |
|-----------------------------------------|------|-------|--------|-------|---------------------------------------|
| Firewall                                | ✓    | ✓     | ✓      | ✓     | nftables                              |
| DNS server                              | ✓    | ✓     | ✓      | ✓     | PowerDNS                              |
| LetsEncrypt certificates                | ✓    | ✓     | ✓      | ✓     | Lego                                  |
| LDAP central authentication             | ✓    | ✓     | ✓      | ✓     | OpenLDAP                              |
| Web server                              | ✓    | ✓     | ✓      | ✓     | nginx                                 |
| Simple web site                         | 𐄂    | 𐄂     | ✓      | ✓     | nginx                                 |
| Mails (SMTP and Submission)             | ✓    | ✓     | ✓      | ✓     | Postfix                               |
| Mails (IMAP and optionally POP3, Sieve) | ✓    | ✓     | ✓      | ✓     | Dovecot                               |
| Full text search                        | 𐄂    | ✓     | ✓      | ✓     | dovecot-fts plugin                    |
| Virtual folders                         | 𐄂    | ✓     | ✓      | ✓     | dovecot virtual folders plugin        |
| Emails auto config for Thunderbird      | ✓    | ✓     | ✓      | ✓     | nginx                                 |
| Emails auto discover for Outlook        | 𐄂    | ✓     | ✓      | ✓     | nginx                                 |
| Antispam                                | 𐄂    | ✓     | ✓      | ✓     | rspamd                                |
| Antispam web interface                  | 𐄂    | ✓     | ✓      | ✓     | rspamd and nginx                      |
| CalDAV / CardDav / Webmail              | 𐄂    | ✓     | ✓      | ✓     | SOGo                                  |
| WebDAV server                           | 𐄂    | 𐄂     | ✓      | ✓     | nginx                                 |
| Jabber server                           | 𐄂    | 𐄂     | ✓      | ✓     | eJabberd                              |
| Antivirus                               | 𐄂    | 𐄂     | 𐄂      | ✓     | ClamAV                                |
| Monitoring                              | 𐄂    | 𐄂     | 𐄂      | ✓     | Prometheus                            |
| Monitoring dashboards                   | 𐄂    | 𐄂     | 𐄂      | ✓     | Grafana from the official web site    |
| Web console access                      | ☐    | ☐     | ☐      | ☐     | optional component, nginx and cockpit |
| Web key directory                       | ☐    | ☐     | ☐      | ☐     | optional component, nginx and GnuPG   |
| Remote backup                           | ☐    | ☐     | ☐      | ☐     | optional component, borg-backup       |
| Wireguard VPN server                    | ☐    | ☐     | ☐      | ☐     | optional component, wireguard VPN     |
| SSH server using certificates           | ☐    | ☐     | ☐      | ☐     | optional for higher security          |
| Simple Git server for users             | ☐    | ☐     | ☐      | ☐     | Small git server over SSH             |


### Requirements

Here some requirements _estimations_, which could vary depending of the traffic, the
number of users, etc:

| Flavour | Minimal memory | Recommended memory |
|---------|----------------|--------------------|
| Mini    | 512MB          | 1GB                |
| Small   | 1GB            | 2GB                |
| Medium  | 2GB            | 4GB                |
| Large   | 4GB            | 4GB or more        |

Even for a small or mini flavour, you can still add components that don't require big
amounts of memory, and see how the system reacts, depending on the traffic, the swap
usage, etc. Some services, like grafana or rspamd, requires more memory. Other services,
like the _Simple web site_ don't requires a lot of CPU nor memory.

### Copy the sample configurations

If you are planning to work with multiple domains, jump to the next section directly.

Once you have chosen your flavour, you need to copy the configuration sample, to create
yours:

```sh
cp config/samples/system-minimal.yml config/system.yml
```

You also need to copy the inventory file for Ansible.

```sh
cp config/samples/hosts.yml config/hosts.yml
```

### Working with multiple domains

To work with multiple domains, use these commands instead, by adjusting `<domain-name>`:

```sh
cp config/samples/system-minimal.yml config/system-<domain-name>.yml
```

Same for the inventory file for Ansible:

```sh
cp config/samples/hosts.yml config/hosts-<domain-name>.yml
```

The inventory should contain this:

```yml
all:
  hosts:
    homebox:
      ansible_host: homebox.example.home
      ansible_user: hbinstall
      ansible_port: 22
      ansible_become: true
```

You can also use the root user if you prefer:

```yml
all:
  hosts:
    homebox:
      ansible_host: homebox.example.home
      ansible_user: root
      ansible_port: 22
```

Then, activate the domain with this command:

```sh
./scripts/switch-domain.sh <domain-name>
```

This will automatically create the symbolic links.

## 2. Define your configuration

You will have to specify:

1. Choose a domain name.
2. Choose a hostname for the system.
3. Create the Ansible inventory to locate your system.
4. The list of users, and their email addresses associated.
5. Optionally, you can override the settings for the services you are installing.

### Choose a domain name

If you already have one, you can skip this section.

With certain limitations, HomeBox allows you to test the solution before buying a domain
name. Just specify the domain name you are planning to buy, and you can buy later when
your system is built.

Once you are ready to buy the domain, you need to choose a provider. Make sure both
extension, aka _Top Level Domain_ and the provider you choose supports DNSSEC. You can
check the provider documentation or support. You can also check the Wikipedia page [list
of Top level domains](https://en.wikipedia.org/wiki/List_of_Internet_top-level_domains)
for the extensions supporting DNSSEC.

This tutorial will use [Gandi](https://gandi.net), but you can use any provider you like.

For this example, we'll use the domain name `sweethome.box`, as `box` supports `DNSSEC`
extensions.

### Choose a host name

If it's not done, perhaps you can choose a hostname for your system. This is important,
because it will be published online, to advertise the services.

I recommend to use something without any technical signification. You can take a word you
like, for instance, but do not use names like _mail_, _smtp_ etc...

For the purpose of this example, we'll simply use _bochica_, the messenger of knowledge of
the Muisca mythology.  You can see more cool names on the [knowledge deities
page](https://en.wikipedia.org/wiki/List_of_knowledge_deities) on Wikipedia.

### Create the inventory

Open the file config/hosts.yml, and modify the values according to your target IP
addresses.

The IP address need to be the one you use for connecting over SSH. If your system is
hosted online, this is probably the public IP address as well. If you work on a LAN, this
could be the local IP address.

```yml
all:
  hosts:
    homebox:
      ansible_host: <replace with your IP address>
      ansible_user: hbinstall
      ansible_port: 22
      ansible_become: true
```

!!! Note If you are connecting to your server with the root user, you can remove the
    `ansible_become: true` line.

Test your configuration with the following command

```sh
ansible homebox -m ping -i config/hosts.yml
```

The output should be like this:

```c
homebox | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### Create the blank configuration

With your text editor, open the file `config/system.yml`.

You now need to modify the users list, in the yml format.

#### Network settings

```yml
###############################################################################
# Domain and hostname information
network:
  domain:           # you-domain
  hostname:         # you-hostname
  external_ip:      # first external IP address, IPv4 or IPv6
  backup_ip:        # if you have one, second external IP address, IPv4 or IPv6,
                    # otherwise, use '~', without the quotes.
  bind_ip:          # If you are behind a NAT, the local IP address externally NAT'ed,
                    # e.g. 192.168.1.10
```

##### For the developers

If your are testing on a local virtual machine and the system is not online, you can use
any valid IPv4 or IPv6 address, as these IPs will only be used to populate the DNS server
entries.

Conversely, the `bind_ip` entry is necessary to ensure the DNS server can listen on a
specific IP address instead of a non-existing one.


#### List of users

Modify the list of users, unless you want to host _Frodo's emails_, or you just want to
test for development.

```yml
users:
  - uid: frodo
    cn: Frodo Baggins
    first_name: Frodo
    last_name: Baggins
    mail: frodo.baggins@{{ network.domain }}
    aliases:
      - frodo@{{ network.domain }}
  - uid: samwise
    cn: Samwise Gamgee
    first_name: Samwise
    last_name: Gamgee
    mail: samwise.gamgee@{{ network.domain }}
    aliases:
      - samwise@{{ network.domain }}
      - sam@{{ network.domain }}
  - uid: peregrin
    cn: Peregrin Took
    first_name: Peregrin
    last_name: Took
    mail: peregrin.took@{{ network.domain }}
    aliases:
      - peregrin@{{ network.domain }}
      - pippin@{{ network.domain }}
  - uid: meriadoc
    cn: Meriadoc Brandybuck
    first_name: Meriadoc
    last_name: Brandybuck
    mail: meriadoc.brandybuck@{{ network.domain }}
    aliases:
      - meriadoc@{{ network.domain }}
      - merry@{{ network.domain }}
```

#### System settings

Unless you are developing, you probably don't need to change these values.

```yml
system:
  release: bookworm
  devel: false
  debug: false
```

#### DNS provider

This section is only needed when you will publish the DNS settings online. Although
HomeBox comes with an integrated DNS server, this server IP address still need to be
published on internet, otherwise, your system would be totally isolated.

There is code present to facilitate the publication of information if you are using
_Gandi_, but you can use any DNS provider.

##### Gandi

If you are using the Gandi DNS provider, you will need to create a personal access token,
as described on the [Gandi
page](https://docs.gandi.net/en/managing_an_organization/organizations/personal_access_token.html).

```yml
dns:
  provider: gandi
```

At the end of the process, you should have your handle and a token:

- handle: `JD461-GANDI`
- key: `SVIs912q5RasCmIZ9YDC1XOc`


#### Optional: Credentials store for _pass_

If you have previously set-up _pass_ on your workstation, you need to ensure credentials
are stored into your password database, by adding the following block in your
configuration file:

```yml
creds_default:
  store: passwordstore
  prefix: '{{ network.domain }}/'
  opts:
    create: ' create=True'
    system: ' length=16 nosymbols=true'
    overwrite: ' overwrite=True'
```

Otherwise, your passwords will be stored in plain text files, albeit only readable from
you.

it should be possible to add another password store fairly easily.
