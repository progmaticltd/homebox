# Default configuration

The default configuration for the Jabber server comes with the following options:

- Installed by default.
- Server to server communication active and public by default.
- Socks proxy to transfer files.
- HTTPs upload for offline file transfer.

Default options for the Jabber server:

```yaml
ejabberd:
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

## Certificates created

Two certificates are created to ensure proper communication with clients and other servers.

| Record     | Type | Purpose                                | Example                  |
|------------|------|----------------------------------------|--------------------------|
| @          | A    | Default certificate used by the server | homebox.space            |
| xmpp       | A    | Handle file transfer over https        | xmpp.homebox.space       |
| conference | A    | S2S conference public URL              | conference.homebox.space |

## Fine tuning

### Disabling server to server communication

To disable s2s communication, set the flag install to false:

``` yaml hl_lines="5 6"
ejabberd:
  install: true
  allow_contrib_modules: false
  # Server-to-server communication
  s2s:
    active: false
```

### Restrict access to only a few servers

You can restrict access to a few trusted domains, for instance:

``` yaml hl_lines="9 10 11"
ejabberd:
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

### Traffic shapper

The traffic shapper values are useful to limit the bandwidth, especially during file transfers:

```yaml
ejabberd:
  shaper:
    normal: 1000
    fast: 50000
    proxyrate: 10240 # file transfer proxy
```

The values are in bytes per second.
