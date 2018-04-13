The main configuration file to create is in the config folder.

There is an example configuration file available in the config folder [system-example.yml](config/system-example.yml).

```
  cd config
  cp system-example.yml system.yml
  ```

The system configuration file is a complete YAML configuration file containing all your settings:

  - Network information
  - Users and groups
  - Some email parameters, like quota and maximum attachment size
  - Some password policies, that are - for now - enforced through the webmail password change interface.
  - Webmail settings (roundcube)
  - Low level system settings, mainly used during the development phase.
  - DNS update credentials (Gandi API key)
  - Firewall policy for SSH
  - Security settings, like AppArmor activation.

The most important settings are the first two sections, the others can be left to their default values.

#### Network details

Every network subdomain entry, email address, etc... will be derivated from these values:

```yaml
###############################################################################
# Domain and hostname information
network:
  domain: homebox.space
  hostname: mail.homebox.space
```

#### User list

The other information you need to fill first is the user list.
You can also [import accounts from other platforms](external-accounts.md).

```yaml
###############################################################################
# Users
users:
- uid: andre
  cn: André Rodier
  first_name: André
  last_name: Rodier
  mail: andre@homebox.space
  password: "iuh*686ni23"
  aliases:
    - andy@homebox.space
    - andrew@homebox.space
  external_accounts:
    - name: gmail
      type: gmail
      user: andre.rodier@gmail.com
      password: jfelcjwmdjslpwmx
      get_junk: true
    - name: free.fr
      type: imap
      host: imap.free.fr
      user: andre.rodier
      password: oim98BVIYswf
```
