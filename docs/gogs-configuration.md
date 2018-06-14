# Default configuration

The default configuration for the Jabber server comes with the following options:

- Installed by default
- Server to server communication active and public by default
- Socks proxy to transfer file
- HTTP upload for offline file transfer

Default options for the Jabber server:

```yaml
gogs_default:
  install: false
  public: false         # not open to public by default
  allow:                # a list of IP address that can access the web interface
    - 192.168.0.0/16    # RFC1918 local networks
    - 172.16.0.0/12
    - 10.0.0.0/8
```

By default, the gogs server is not installed.
If you install the git server, you can choose to restrict it to your local network (by default),
or to make your git repository public.

## Required domain

If you are entering your DNS records yourself, this is the records you need to create:

| Record            | Type   | Purpose                                  | Example                      |
| -----------       | ------ | ---------                                | ---------                    |
| gogs              | A      | Web site access                          | gogs.homebox.space           |

The domains are created automatically if you are using the DNS update script with Gandi, or if you are
using the embedded DNS server.

## Certificates created

Two certificates are created to ensure proper communication with clients and other servers.

| Record            | Type   | Purpose                                  | Example                      |
| -----------       | ------ | ---------                                | ---------                    |
| gogs              | A      | Handle repository access over https      | gogs.homebox.space           |
