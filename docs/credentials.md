## Credentials

Any password, for the system or for users are dynamically generated, and saved on the deployment workstation.

### Plain text passwords

By default, these passwords are stored in plain text, on the workstation, in a folder named after the domain:

```
backup/<domain>/credentials/
```

### GPG encrypted passwords

If you are using _pass_, it is possible to use it to store the credentials generated. In this case, this is the way to
save them:

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
