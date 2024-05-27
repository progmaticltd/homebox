# Dedicated archives storage

This optional step, for advanced users, allows you to use a dedicated storage for the user files, i.e.:

- One fast but smaller and more expensive storage device, for instance for the daily emails, in `/home/users`.
- A slower but bigger and cheaper storage for the email archives, and other files not requiring fast access, in
  `/home/archives`.

This page explains the installation of a dedicated _live_ storage, i.e. the current emails received.

This is specially useful for some cloud providers, offering SSD and HD block storage, but can be also relevant for a
home server.

Because when installing homebox, files and directories are created in these folders, it is an absolute requirements to
run these playbooks _before_ running the installation itself.

## Pre-requisites

### Clone the homebox-extra-modules

The [extra modules repository](https://github.com/progmaticltd/homebox-extra-modules) is hosted on GitHub.

You can clone at any place, but the repository roles should be accessible by the main Ansible project, for instance, if
you store everything in a folder called `homebox-all`:

```sh
cd ~/Projects/homebox-all
git clone git@github.com:progmaticltd/homebox-extra-modules.git
```

```plain
ls -l
drwx------ 1 frodo frodo 320 May 25 12:56 homebox
drwx------ 1 frodo frodo  36 Sep 17  2023 homebox-extra-modules
```

### Let Ansible find the new roles

And your Ansible configuration should contains the path relative to the playbooks:

```ini
[defaults]
retry_files_enabled = False
display_skipped_hosts = False
stdout_callback = yaml
callback_enabled = profile_roles
roles_path = {{ playbook_dir }}/../../roles/:{{ playbook_dir }}/../../../homebox-extra-modules/roles/
connection_plugins = {{ playbook_dir }}/../../common/connection-plugins/
filter_plugins = {{ playbook_dir }}/../../common/filter-plugins/
remote_tmp = /tmp/
inventory=../config/hosts.yml
```


## Identify the storage devices

You can identify the attached storage using the `lsblk` command:

```plain
root@debian:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0     11:0    1 1024M  0 rom
vda    254:0    0    8G  0 disk
├─vda1 254:1    0    7G  0 part /
├─vda2 254:2    0    1K  0 part
└─vda5 254:5    0  975M  0 part [SWAP]
vdb    254:16   0    4G  0 disk
vdc    254:32   0   20G  0 disk
```

## Configure the "live" storage

### Customise the storage settings

You can customise the settings from the default ones, by copying this block to your configuration file `system.yml`:

```yml
storage_live:
  device: /dev/vdb
  fstype: btrfs
  mkfs_opts:
    - -R quota
    - --checksum xxhash
  mount_opts:
    - noatime
    - compress=lzo
```

The important value to check, if the storage you decide to dedicate to "live" emails, in this case, `/var/vdb`.

### Run the playbook to create the live storage

The syntax is fairly simple:

```sh
cd homebox/playooks
ROLE=home-live-storage ansible-playbook install.yml
```

The playbook is doing the following:

- Create the partitions, and format them, using btrfs by default
- Create the systemd services to automatically mount these partitions.

Once run, you can see the storage using the same `lsblk` command:

```plain
root@debian:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0     11:0    1 1024M  0 rom
vda    254:0    0    8G  0 disk
├─vda1 254:1    0    7G  0 part /
├─vda2 254:2    0    1K  0 part
└─vda5 254:5    0  975M  0 part [SWAP]
vdb    254:16   0    4G  0 disk
└─vdb1 254:17   0    4G  0 part /home/users
vdc    254:32   0   20G  0 disk
```

And check the systemd service:

```plain
root@debian:~# systemctl cat home-users.mount
# /etc/systemd/system/home-users.mount
[Unit]
Description=Users’ live storage

[Mount]
What=LABEL=arda-world-home-users
Where=/home/users
Type=btrfs
Options=noatime,compress=lzo

[Install]
WantedBy=multi-user.target
```

Using a label for the source allows you to re-attach the live storage without changing a system settings in case of
disaster recovery.
