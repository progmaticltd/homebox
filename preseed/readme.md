# Preseed folder

This step is only required if you want to build a Debian automatic installation disc.

The whole precedure build an ISO image with the hostname set, the root password, etc.

It will be the basic requireements before running the Ansible scripts.

There is

It can be used both for development with a VM or for production to install the operating system base.

## 1. Customisation
Copy system-example.yml to system.yml, and modify the values accordingly.
There is actually two flavours, one is a fully encrypted drive with a passphrase,
while the second one installs on a machine with two drives and software RAID.

## 2. Setup SSH authentication
Copy your public key into the folder `config/authorized_key`. This file will be copied into the
`/root/.ssh/authorized_keys` by the automatic installer for you to connect using public key authentication.


## 3. Build the ISO image
Then, run this command to build the ISO image:

```
docker-compose build cdbuild
docker run -v /tmp:/tmp -t -i cdbuild:latest
```

This will create the ISO images in /tmp/build-${hostname}/${hostname}-install.iso folder.

The whole installation should be automatic, with LVM and software RAID.
For LVM, there is a volume called "reserved" you can remove. This will let
you resize the other volumes according to your needs.

