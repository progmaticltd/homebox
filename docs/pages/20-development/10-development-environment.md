# Development environment

This section will help you to set-up a full development environment, from the Ansible host to the target system.

## Packages to install

The following packages are necessary for the development:

| Package      | Notes                                        |
|--------------|----------------------------------------------|
| ansible      | Required to run the playbooks.               |
| git          | No advanced git plugin used so far.          |
| yamllint     | Ensure YAML files are syntaxically correct.  |
| ansible-lint | Ensure playbooks and tasks files compliance. |

You can also use these extra packages:

| Package      | Notes                                                                     |
|--------------|---------------------------------------------------------------------------|
| shellcheck   | Required to check the validity of any shell script included.              |
| markdownlint | Ensure the documentation files are using the same standards.              |
| aspell       | Spell checker for the markdown documentation, written in British English. |

It is also recommended to use a text editor that highlighting errors and warning on the fly, for convenience and to
avoid pushing erroneous code.


## Ansible configuration file


### Basic version

A sample configuration file is included in the `common` folder, just copy it to `ansible.cfg`:

```ini
[defaults]
retry_files_enabled = False
display_skipped_hosts = False
stdout_callback = yaml
roles_path = .:{{ playbook_dir }}/../../roles/
inventory = ../config/hosts.yml
filter_plugins = {{ playbook_dir }}/../../common/filter-plugins/
```

The filter plugins only contains `wkd_hash`, using by the _web keys directory_ role.


### Extra and cloud repositories

If you are using other repositories, for instance the ones below:

- [Extra features modules](https://github.com/progmaticltd/homebox-extra-modules)
- [Cloud specific modules](https://github.com/progmaticltd/homebox-cloud-modules)

You can include them using the `ansible-full-example.cfg`:

```ini
[defaults]
retry_files_enabled = False
display_skipped_hosts = False
stdout_callback = yaml
callback_enabled = profile_roles
roles_path = {{ playbook_dir }}/../../../homebox-cloud-modules/roles/:{{ playbook_dir }}/../../../homebox-extra-modules/roles/:{{ playbook_dir }}/../../roles/
connection_plugins = {{ playbook_dir }}/../../common/connection-plugins/
filter_plugins = {{ playbook_dir }}/../../common/filter-plugins/
remote_tmp = /tmp/
inventory=../config/hosts.yml
```

The connection plugins contains only one plugin to use [fwknow](https://www.cipherdyne.org/fwknop/) with ssh.


## Target system

The target system will be used for development, and need to be a full _Debian_ environment, like:

- A virtual machine using KVM or any other virtualisation environment.
- A cloud server, for instance on Vultr, Linode, etc...
- A physical system attached to your network.

You cannot use containerisation like Docker, as this doesn't support systemd services, for one reason. There is no plan
to support containers at this time, and probably there won't be.

## Copy the sample configuration

First, choose a domain name. You can use a real one, even you are not (yet) the owner, and you will see later how to
test it.

There is a sample configuration in the `config/samples` folder. In this example, we will use the domain name
`arda.world` and the hostname `middle-earth`:

```sh
cp config/samples/hosts.yml config/hosts-arda.world.yml
cp config/samples/system.yml config/system-arda.world.yml
```

Review the system settings with an editor. One value to change, is probably the _devel_ flag, and maybe the _debug_ one,
and set them to _true_:

```yml
system:
  devel: true
  debug: true
```


Now, activate the domain:

```plain
./scripts/switch-domain.sh arda.world
Switching configuration file to domain 'arda.world'.
External IP address: ~
Backup IP address: ~
```

This will create the symbolic links `hosts.yml` and `system.yml`, so you can work with multiple domains easily.

## About the IP addresses

You can set any external IP addresses, both for the backup and the main one, this doesn't matter yet, but you shouldn't
use private IP addresses.

```yml
network:
  domain: arda.world         # your domain name, e.g. arda.world
  hostname: middle-earth     # your hostname, middle-earth
  external_ip: 12.33.44.55   # first external IP address, IPv4 or IPv6
  backup_ip: ~               # if you have one, second external IP address, IPv4 or IPv6, otherwise, use ~
  bind_ip: 172.20.1.81       # If you are behind a NAT, the local IP address externally NAT'ed,
```

When developing, or when your server is behind _NAT'ed_, it is necessary to specify the local IP address some services,
like the DNS server will use to "bind".

## About the certificates

On the first installation, whatever the system is a real or a development one, the certificates are self-signed, for two
reasons:

- The system is not yet online, and the certificates are created using the
  [DNS challenge method](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge).
- Most of the services need a certificate to run (e.g. openldap, dovecot, postfix, etc.)

Still, all the certificates are created using the same certificate authority, which is registered and trusted by the
system. Once a system is installed, you can see the certificates status using the `cert-status` command.
