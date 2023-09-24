## Credentials

Any password, for the system or for users are dynamically generated, and saved on the deployment workstation.

### Plain text passwords

By default, these passwords are stored in plain text, on the workstation, in a folder named after the domain:

```
backup/<domain>/credentials/
```

In the example above, passwords will be stored in the _backup_ folder in homebox, using the domain name
“mydomain.io”. __This folder is automatically exclude from git__.


### GPG encrypted passwords

If you are using _pass_, it is possible to use it to store the credentials generated. In this case, you need to override
the password store, like this, in your system.yml file:

```yml
# Credentials store to use
creds:
  store: passwordstore
  prefix: '{{ network.domain }}/'
  opts:
    create: ' create=True'
    # Used for system, should be safe without quoting, but long enough to be secure
    system: ' length=16 nosymbols=true'
    overwrite: ' overwrite=True'
```

For reference, see https://docs.ansible.com/ansible/latest/collections/community/general/passwordstore_lookup.html

### Security options

Security options are detailed on the [security page](security-configuration.md).
The default settings are:

- Automatically install security updates using unattended upgrades.
- Reboot the server during the night when the kernel has been upgraded.
- Send email alerts to the postmaster.
- Force root SSH login to use public key cryptography, and not a password.
- Disable the root password.

Other options are possible, see the security page for details.
