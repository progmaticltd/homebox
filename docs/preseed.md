This step is only required if you want to build a Debian installation disc - before running the Ansible scripts. It does not install the homebox server software stack.

However, the whole precedure build an automatic installer with the hostname set, the root password, and the drive fully encrypted by the key you specify in the configuration file!

This script can be used both for development with a virtual machine or for production to install the operating system base.

Once installed, the system drive will be fully encrypted with [LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup).

# Customisation

Copy system-example.yml to system.yml, and modify the values accordingly.

Example:

```yaml

# System configuration sample 1: Encrypted hard drive
system:
  hostname: mail
  passphrase: I will not give you my password
  preseed: luks
  versio
  arch: amd64
  boot_timeout: 5   # In seconds

# The proxy is optional. When specified, it is used to configure apt
network:
  domain: example.com
  iface: auto            # or use eth0, ens3, etc...

# Country and locales definition
country:
  code: uk
  timezone: Europe/London

locale:
  id: en_GB
  language: en
  country: UK
  charset: UTF-8
  keymap: gb

# Repository specific values
repo:
  release: stretch
  main: ftp.uk.debian.org
  security: security.debian.org
  sections: main contrib non-free

# Clock parameters
clock:
  utc: true
  ntp: true

# Accounts informations
# You can choose a strong password here,
root:
  password: H0meb0x

# Debug: As it states
debug: true

```

There is actually two flavours, one is a fully encrypted drive with a passphrase,
while the second one installs on a machine with two drives and software RAID.

See system-example.yml for reference.

# Setup SSH authentication

Copy your public key into the folder `config/authorized_key`. This file will be copied into the
`/root/.ssh/authorized_keys` by the automatic installer for you to connect using public key authentication.

# Build the ISO image

Then, run this command to build the ISO image:

```sh

docker-compose build cdbuild
docker run -v /tmp:/tmp -t -i cdbuild:latest

```

This will create the ISO images in `/tmp/build-${hostname}/${hostname}-install.iso` folder,
for instance `/tmp/homebox/homebox-install.iso`

The whole installation should be automatic, with LVM and software RAID.
For LVM, there is a volume called "reserved" you can remove. This will let
you resize the other volumes according to your needs.

