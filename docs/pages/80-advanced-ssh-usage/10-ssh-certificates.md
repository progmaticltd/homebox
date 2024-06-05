# SSH certificates

## Basic usage

```sh
ROLE=ssh-server-base ansible-playbook install.yml
```

Once installed, the following will be set:

- An SSH server certificate will be generated.
- The SSH server configuration to allow the members of the group _mail-users_, if some
  users have an SSH public key defined.


## Administration account

This step is optional. This will let you use the dedicated _admin_ account over SSH,
rather than the _root_ account, to administer your server.

The _administration user_, which is in the _sudo_ group, will be configured for SSH
access, and an SSH certificate will be created with a limited validity time of your
choice.

```yaml
system:
  […]
  admin:
    ssh_auth:
      public_key:
        comment: admin-key
        type: ecdsa-sha2-nistp256
        data: >-
          AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBInV8YG
          /UujelRuNkcytzcOj7mYfDzHq4Q+EcdUz9VsIyNC3dJ1oE3s49w/VPV/9pN
          ZZQWoFX+HLLYkM8RRizwU=
      password: false
      validity: +52w
```

- An SSH client configuration file will be generated and saved in the backup directory.
- The public key will be signed by the server certificate file will be saved in the backup
  directory
- The keys and the configuration files will be saved in your `~/.ssh` folder as well.

!!! Note
    If you set _password_ to true, this user will be allowed to authenticate on the
    server using a password as well. This is mostly useful to avoid being locked out of
    your server, with a degradation of security, though.

The configuration will create an SSH configuration file with an _alias_ `admin.<domain>`:

```plain
# Configuration for the key admin-key
# Copy this file in your ~/.ssh folder, and
# add he following line in your ~/.ssh/config file:
# Include ~/.ssh/admin-f29da72a.conf
Host admin.arda.world
  Hostname middle-earth.arda.world
  VerifyHostKeyDNS no
  User admin
  IdentityFile ~/.ssh/admin-f29da72a
  CertificateFile ~/.ssh/admin-f29da72a-cert.pub
  HostKeyAlias middle-earth.arda.world
  PasswordAuthentication no
```

Make sure you have the following line in your `~/.ssh/config`:

```conf
Include ~/.ssh/*-ssh.conf
```

## Check the installation

Once installed, you can check if the installation has been successful with the command
below.


```sh
ROLE=ssh-server-base ansible-playbook check.yml
```

It will display the server certificate and the administration key, if you chose to use
one:

```plain
[...]

TASK [ssh-server-base : Show the server cert] **********************************
ok: [homebox] =>
  msg: |-
    middle-earth.arda.world-cert.pub:
            Type: ssh-ed25519-cert-v01@openssh.com host certificate
            Public key: ED25519-CERT SHA256:eTEYSRRskM/rc33kIiUaR1W6x5ea+BRifKWSZ+Rw6Fo
            Signing CA: ED25519 SHA256:eTEYSRRskM/rc33kIiUaR1W6x5ea+BRifKWSZ+Rw6Fo (using ssh-ed25519)
            Key ID: ""
            Serial: 0
            Valid: forever
            Principals:
                    middle-earth.arda.world
                    arda.world
                    *.arda.world
            Critical Options: (none)
            Extensions: (none)

[...]

TASK [ssh-server-base : Show the admin key settings] ***************************
ok: [homebox] =>
  msg: |-
    /home/andre/Projects/homebox/playbooks/../backup/arda.world/ssh/users/admin/admin-f29da72a-cert.pub:
            Type: sk-ssh-ed25519-cert-v01@openssh.com user certificate
            Public key: ED25519-SK-CERT SHA256:KPyCM3K76OR0gx6bGeNOC48HXWvfEEpuXMXkL+6UxjE
            Signing CA: ED25519 SHA256:eTEYSRRskM/rc33kIiUaR1W6x5ea+BRifKWSZ+Rw6Fo (using ssh-ed25519)
            Key ID: "admin-admin-f29da72a"
            Serial: 0
            Valid: from 2024-05-26T18:43:00 to 2025-05-25T18:44:58
            Principals:
                    admin
            Critical Options: (none)
            Extensions:
                    permit-pty
                    permit-user-rc

```

When connecting using the `ssh -v` option, you should see a line similar to this one:

```sh
ssh -v admin.arda.world
[...]
Host 'middle-earth.arda.world' is known and matches the ED25519 host key.
[...]
```

## Backup the keys

Once installed, you can backup the server’s keys, so you can restore them later. The keys
will be stored in the backup folder, protected by a random passphrase. The passphrase will
be stored into _pass_ or in the credentials folder otherwise.

```sh
ROLE=ssh-server-base ansible-playbook backup.yml
```


## Restoring the keys

If you need to rebuild your server, you can restore the keys that were used before, using
the following command:

```sh
ROLE=ssh-server-base ansible-playbook restore.yml
```


## Uninstalling

Like any other role, you can uninstall the certificate settings, using the following
command:


```sh
ROLE=ssh-server-base ansible-playbook uninstall.yml
```

!!! warning
    Make sure you still have access to your server, i.e. you have root or admin
    access with a standard private key.
