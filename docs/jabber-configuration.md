# Default configuration

The default configuration for the Jabber server comes with the following options:

- Installed by default
- Server to server communication active and public by default
- Socks proxy to transfer file
- HTTP upload for offline file transfer

Default options for the Jabber server:

```yaml
ejabberd_default:
  install: true
  allow_contrib_modules: false
  # Server-to-server communication
  s2s:
    active: true
    use_starttls: required_trusted
    public: true
    trust:
      - jabber.org
  # https upload module
  http_upload:
    port: 5443
    secret_length: 40
    max_size: 104857600
    thumbnail: true
  # direct file transfer
  file_transfer:
    port: 7778
  # traffic shaper
  shaper:
    normal: 1000
    fast: 50000
    proxyrate: 10240 # file transfer proxy

```

## Required domain

If you are entering your DNS records yourself, this is the records you need to create:


| Record            | Type   | Purpose                                  | Example                      |
| -----------       | ------ | ---------                                | ---------                    |
| xmpp              | A      | Handle file transfer                     | xmpp.homebox.space           |
| conference        | A      | S2S conference public URL                | conference.homebox.space     |
| _xmpp-client._tcp | SRV    | Client to server automatic configuration | 5 0 5222 xmpp.homebox.space  |
| _xmpp-server._tcp | SRV    | Server to server automatic configuration | 5 0 5269 xmpp.homebox.space  |

The domains are created automatically if you are using the DNS update script with Gandi.

## Certificates created

Two certificates are created to ensure proper communication with clients and other servers.

| Record            | Type   | Purpose                                  | Example                      |
| -----------       | ------ | ---------                                | ---------                    |
| @                 | A      | Default certificate used by the server   | homebox.space                |
| xmpp              | A      | Handle file transfer over https          | xmpp.homebox.space           |
| conference        | A      | S2S conference public URL                | conference.homebox.space     |

## Disabling server to server communication

To disable s2s communication, set the flag install to false:

```yaml
ejabberd_default:
  install: true
  allow_contrib_modules: false
  # Server-to-server communication
  s2s:
    active: false
```

## Restrict access to only a few servers

You can restrict access to a few trusted domains, for instance:

```yaml
ejabberd_default:
  install: true
  allow_contrib_modules: false
  # Server-to-server communication
  s2s:
    active: true
    use_starttls: required_trusted
    public: false
    trust:
      - jabber.org
      - exemple.com
```

# Traffic shapper

The traffic shapper values are useful to limit the bandwidth, especially during file transfers:

```yaml
  # traffic shaper
  shaper:
    normal: 1000
    fast: 50000
    proxyrate: 10240 # file transfer proxy
```

The values are in bytes per second.
