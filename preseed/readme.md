# Preseed folder
This step is only required if you do not have a ready to use Debian server, and you want to quickly setup one.

The preseed folder contains scripts to create an iso imag for Debian Stretch, with automatic installation.
It is set to install your system on two disks with software RAID and LVM,
although this setup will be made optional.
It can be used both for development with a VM or for production to install the operating system base.

## 1. Create the hosts.yml configuration
There is two hosts that need to be defined. One that will run the Ansible scripts,
and one that will be used as the mail server.

- Copy the file config/hosts-example.yml into config/host.yml
- Update your hosts definition

I personally use my workstation to run the Ansible scripts, and a virtual machine with snapshots for development.

## 1. Setup SSH authentication:
Copy your public key in `preseed/misc/root/.ssh/authorized_key`. This file is ignored by git.
This key will be copied into the `/root/.ssh/authorized_keys` by the automatic installer
for you to connect to your Linux server

## 2. Customisation:
Copy common.example.yml to common.yml, and modify the values accordingly.

- The disk names will need to be modified for an automatic installation
  - For a virtual machine, the disks might be called vda and vdb, but sda and sdb for a physical server.
  - The network configuration, especially the domain name you want to use
  - The country and the locale values
  - The timezone
  - The root password

## 3. Build the ISO image
Then, inside the preseed folder, run this command to build the ISO image:

`ansible-playbook -v -i ../config/hosts.yml playbooks/build-cd.yml`

This will create the ISO images in /tmp folder. Use the DVD one for automatic installation.

## 4. Use a physical server or a VM to run the Debian installer.
The whole installation should be automatic, with LVM and software RAID
For LVM, there is a volume called "reserved" you can remove. This will let
you resize the other volumes according to your needs.

