# Default configuration

The default configuration for the Gogs server comes with the following options:

- Not installed by default
- URL not public by default, only accessible from a local network
- Repositories excluded from backup

Default options for the Gogs server:

``` yaml hl_lines="4"
# Gogs installation with LDAP authentication.
# The super administrator is "postmaster" for now.
gogs_default:
  install: false        # Not installed by default
  public: false         # Not open to public by default
  backup: false         # When a backup is configured, exclude the repositories
                        # from back up. Set the flag to true to include them.
  allow:                # A list of IP address that can access the web interface
    - 192.168.0.0/16    # RFC1918 local networks
    - 172.16.0.0/12
    - 10.0.0.0/8
```

By default, the gogs server is not installed.
If you install the git server, you can choose to restrict it to your local network (by default),
or to make your git repository public.

# Certificates created

Two certificates are created to ensure proper communication with clients and other servers.

| Record      | Type   | Purpose                             | Example            |
| ----------- | ------ | ---------                           | ---------          |
| gogs        | A      | Handle repository access over https | gogs.homebox.space |
