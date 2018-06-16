# Default configuration

The default configuration for the Transmission daemon comes with the following options:

- Not installed by default
- URL not public by default, only accessible from a local network
- Web interface over https
- Require encryption
- DHT end PEX options enabled
- No speed limit
- Destination folder set to "/var/lib/transmission-daemon/downloads"

Default options for the transmission daemon:

```yaml
###############################################################################
# Transmission bittorrent client installation
transmission_default:
  install: false
  public: false         # not open to public by default, only to local networks
  allow:                # a list of IP address that can access the web interface
    - 192.168.0.0/16    # RFC1918 local networks
    - 172.16.0.0/12
    - 10.0.0.0/8
  # Block list
  # example: http://john.bitsurge.net/public/biglist.p2p.gz
  blocklist_url: ~
  # Protocol options
  pex: true
  dht: true
  port_forwarding: false
  # Encryption parameters
  # 0 = unencrypted, 1 = prefer encrypted, 2 = require encrypted
  encryption: 2
  # Directories
  download_dir: /var/lib/transmission-daemon/downloads
  incomplete_dir: ~
  # Download limits
  speed_limit_down: 0
  download_limit: 100
  download_queue: 5
  # Upload limits
  speed_limit_up: 0
  upload_limit: 100
  seed_queue_size: 5
```

## Required domain

If you are entering your DNS records yourself, this is the records you need to create:

| Record            | Type   | Purpose                                  | Example                      |
| -----------       | ------ | ---------                                | ---------                    |
| transmission      | A      | Web site access                          | transmission.homebox.space   |


The domains are created automatically if you are using the DNS update script with Gandi, or if you are
using the embedded DNS server.

## Certificates created

Two certificates are created to ensure proper communication with clients and other servers.

| Record       | Type   | Purpose                             | Example                    |
| -----------  | ------ | ---------                           | ---------                  |
| transmission | A      | Handle repository access over https | transmission.homebox.space |
