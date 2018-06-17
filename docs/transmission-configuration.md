# Default configuration

The default configuration for the Transmission daemon comes with the following options:

- Not installed by default
- URL not public by default, only accessible from a local network
<<<<<<< HEAD
=======
- The web interface and the RPC servers are protected with the LDAP credentials.
- Downloaded files can be accessed within your web browser, still using the LDAP credentials.
- The daemon runs in a proper AppArmor profile.
>>>>>>> dev-arodier
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
  incomplete_dir: /var/lib/transmission-daemon/incomplete
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

| Record       | Type   | Purpose         | Example                    |
| -----------  | ------ | ---------       | ---------                  |
| transmission | A      | Web site access | transmission.homebox.space |


The domains are created automatically if you are using the DNS update script with Gandi, or if you are
using the embedded DNS server.

## Certificates created

Two certificates are created to ensure proper communication with clients and other servers.

| Record       | Type   | Purpose                             | Example                    |
| -----------  | ------ | ---------                           | ---------                  |
| transmission | A      | Handle repository access over https | transmission.homebox.space |

## Access from Android

Install the Transmission remote client for Android on [Google Play](https://play.google.com/store/apps/details?id=com.neogb.rtac).

<<<<<<< HEAD
## Access from a web browser

You can access the web interface from any web browser, using https://transmission.example.com.
Authentication is done using the same username and password as your emails.
=======
## Monitor and start downloads from a web browser

You can access the web interface from any web browser, using https://transmission.example.com.
If you are not coming from a trusted IP address, you will have to enter a user name and a password.
the authentication is done using the LDAP credentials.

## Downloading files from your web browser

You can access the files downloaded from any web browser, using https://transmission.example.com/downloads/.
If you are not coming from a trusted IP address, you will have to enter a user name and a password.
the authentication is done using the LDAP credentials.
A nice and responsive web interface has been added to search files.
>>>>>>> dev-arodier
