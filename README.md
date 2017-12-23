
A set of Ansible scripts to setup your personal mail server (and more) for your home...

# Table of contents

* [Introduction](#introduction)
* [Folders:](#folders)
* [Preseed folder](#preseed-folder)
   * [1. Create the hosts.yml configuration](#1-create-the-hostsyml-configuration)
   * [1. Setup SSH authentication:](#1-setup-ssh-authentication)
   * [2. Customisation:](#2-customisation)
   * [3. Build the ISO image](#3-build-the-iso-image)
   * [4. Use a physical server or a VM to run the Debian installer.](#4-use-a-physical-server-or-a-vm-to-run-the-debian-installer)
* [Mail server installation](#mail-server-installation)
   * [Copy the example files to create your basic setup](#copy-the-example-files-to-create-your-basic-setup)
   * [Run the Ansible scripts to setup your email server](#run-the-ansible-scripts-to-setup-your-email-server)
* [What do you need for production usage?](#what-do-you-need-for-production-usage)
   * [Basic requirements](#basic-requirements)
   * [Automatic update of the DNS entries](#automatic-update-of-the-dns-entries)

## Introduction
This project has been created for those who simply want to host their emails at home,
and don't want to manage the full installation process manually, from scratch.

It is made to be unobtrusive, standard compliant, secure, robust, extensible and automatic

- Unobtrusive: The base distribution (Debian) is only slightly modified. Once installed, you can use it normally, and install the packages you want.
- Standard compliant: For instance, the system not only generate the DKIM records, it publish them for you on Gandi DNS server!
- Secure: The LDAP server is setup to store passwords encrypted. Password policies and default password policy are setup as well, although not activated yet. I pay a beer / a glass of wine / etc to the first one who find what is wrong, in London or remotely ;-). See the 'account' role for details.
- Robust: the DNS records update script is very safe, and you can run it in test mode. In this mode, the new zone version will be created, but not activated. If there is no change to your DNS record, the new version will be deleted.
- Extensible: By using LDAP for user authentications, you can use other software, like nextcloud, gitlab or even an OpenVPN server, without having to remember more passwords.
- Automatic: Most tasks are automated. Even the external IP address detection and DNS update process. In theory, you could use this with a dynamic IP address.

__Notes__:

- This is a work in progress and a project I am maintaining on my spare time. Although I am trying to be very careful, there might be some errors. In this case, just fill a bug report, or take part.
- I am privileging stability over features. The master branch should stay stable for production.
- This is a work in progress, some features are missing, although the current version can be installed. Postfix and Dovecot are actually configured at the simplest level
- I haven't added the firewall rules yet

__TODO__:

I am planning to add / test the following features, in *almost* no particular order:

- DMARC: Records publication and DMARC implementation
- Automatic configuration for Thunderbird and Outlook
- Add a caldav / carddav server (Any that works with LDAP authentication)
- Add a jabber server (Any that works with LDAP authentication)
- Add optional components (e.g. [Gogs](https://gogs.io/), [openvpn](https://openvpn.net/), [Syncthing](https://syncthing.net/), etc)
- Test other mail systems, like Cyrus, Sogo, etc.

## Folders:
- config: Ansible hosts file Configuration.
- preseed: Ansible scripts to create an automatic ISO image installer for the base system.
- install: Ansible scripts to install the mail server environment.

## Preseed folder
This step is only required if you do not have a ready to use Debian server, and you want to quickly setup one.

The preseed folder contains scripts to create an iso imag for Debian Stretch, with automatic installation.
It is set to install your system on two disks with software RAID and LVM,
although this setup will be made optional.
It can be used both for development with a VM or for production to install the operating system base.

### 1. Create the hosts.yml configuration
There is two hosts that need to be defined. One that will run the Ansible scripts,
and one that will be used as the mail server.

- Copy the file config/hosts-example.yml into config/host.yml
- Update your hosts definition

I personally use my workstation to run the Ansible scripts, and a virtual machine with snapshots for development.

### 1. Setup SSH authentication:
Copy your public key in `preseed/misc/root/.ssh/authorized_key`. This file is ignored by git.
This key will be copied into the `/root/.ssh/authorized_keys` by the automatic installer
for you to connect to your Linux server

### 2. Customisation:
Copy common.example.yml to common.yml, and modify the values accordingly.

- The disk names will need to be modified for an automatic installation
  - For a virtual machine, the disks might be called vda and vdb, but sda and sdb for a physical server.
  - The network configuration, especially the domain name you want to use
  - The country and the locale values
  - The timezone
  - The root password

### 3. Build the ISO image
Then, inside the preseed folder, run this command to build the ISO image:

`ansible-playbook -v -i ../config/hosts.yml playbooks/build-cd.yml`

This will create the ISO images in /tmp folder. Use the DVD one for automatic installation.

### 4. Use a physical server or a VM to run the Debian installer.
The whole installation should be automatic, with LVM and software RAID
For LVM, there is a volume called "reserved" you can remove. This will let
you resize the other volumes according to your needs.


## Mail server installation

First, check that you can login onto your mail server, using SSH on the root account:

`ssh root@mail.example.com`

Replace mail.example.com with the address of your mail server.
This will also add the server to your known_hosts file

### Copy the example files to create your basic setup

Run the following code to create your custom files

```
  cd install/playbook/variables
  cp accounts.example.yml accounts.yml
  cp common.example.yml common.yml
  cp dovecot.example.yml dovecot.yml
  cp postfix.example.yml postfix.yml
  cp webmail.example.yml webmail.yml
```

File contents
- common.yml: common variables and basic network configuration (domain)
- accounts.yml: User and group accounts information
- dovecot.yml: Dovecot mail server configuration
- postfix.yml: Postfix MTA configuration
- webmail.yml: Webmail (roundcube) configuration

### Run the Ansible scripts to setup your email server
The installation folder is using Ansible to setup the mail server
For instance, inside the install folder, run the following command:

`ansible-playbook -vv -i ../config/hosts.yml playbooks/install.yml`

The script is actually doing following:

- Install some required packages.
- Install a simple LDAP server (openLDAP).
- Create a valid certificate, and activate TLS authentication for the LDAP server.
- Create the user and group accounts in the directory.
- Integrate the LDAP accounts into the system using pam_ldap and nslcd (optional).
- Install Postfix mail transfer agent, with a dedicted SSL certificate.
- Create a DKIM key, and publish the associated DNS record.
- Update the SPF records with your external IP address.
- Install Dovecot mail server, with a dedicated SSL certificate for IMAP.
- Install PostgreSQL for the database.
- Install Roundcube with nginx, and create a dedicated SSL certificate for the webmail.

The certificates are generated using LetsEncrypt service, with one for each service. Examples for example.com domain:
  - openldap: ldap.example.com
  - postfix: smtp.example.com
  - dovecot: imap.example.com
  - the webmail: webmail.example.com
  
The generated certificates and DKIM keys will be automatically saved on your local computer, into the backup folder. This folder is ignored by git. If you restart the installation from scratch using a new server, these certificates and DKIM keys will be used, so you do not end up requesting more certificates or updating your DNS server more than necessary.

## What do you need for production usage?
### Basic requirements

- A low consumption hardware box to plug on your router.
- A computer to run the Ansible scripts.
- A static IP address from your ISP (Not mandatory, but works better)
- Some basic newtork knowledge

For automatic DNS records creation and update:
- A registered domain name, with [Gandi](https://gandi.net/)

### Automatic update of the DNS entries
A custom script automatically register domains entries to Gandi, if you provide an API key.
This is useful so you do not have to manage the entries yourself, or if even if you don't have a static IP address.

Here what to do to obtain an API key:

1. Visit the [API key page on Gandi](https://www.gandi.net/admin/api_key)
2. Activate of the API on the test platform.
3. Activate of the production API

Your API key will be activated on the test platform.

__Notes:__

- The initial creation of DNS records for certificate generation should take some time, I am working on a solution.
- DNS automatic update is actually limited to Gandi, but it should be easy to add more.
- Once the script has been run, the backup folder contains your certificates and DKIM public keys. If you are rebuilding your server from scratch, the same certificates and keys will be used.

