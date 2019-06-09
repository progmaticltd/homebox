
# Introduction

This section will explains all the necessary steps _before_ the installation really starts, like the DNS records or your
home network set-up.

It is not a "Self hosting for newbies", but if you follow the instructions carefully, you do not need strong technical
knowledge to achieve the above.

You still need some basic understanding though, like what is an IP address or a port, how to run Ansible in a console,
how to edit Yaml files, etc.

If something goes wrong, here a few resources:

- The [Postfix mailing lists](http://www.postfix.org/lists.html).
- The [Dovecot mailing lists](https://www.dovecot.org/mailinglists.html).
- The [Debian mailing lists](https://lists.debian.org/).
- Our [github page](https://github.com/progmaticltd/homebox)
- Finally, [Duckduckgo](https://duckduckgo.com/) or [Google](https://google.com/).

## Folders content

The repository contains a few folders you should be familiar with:

- config: The main Yaml configuration files for your homebox device.
- preseed: Docker environment to create an automatic ISO image installer for Debian.
- install: Ansible scripts to install or test the whole server environment.
- backup: A very useful folder that contains some important files like the passwords and certificates generated when
  deploying the system. This allows you to "replay" the deployment on a new server after a disaster, without loosing any
  information. This folder is generated automatically on the first deployment, and ignored by git
- tests: Ansible playbooks to test the platform.
- sandbox: Put anything you don't want to commit here.
- docs: This project documentation.
- uninstall: Ansible scripts to uninstall some of the components. This allows you to test them.

## Conditions required to host emails

### Host emails at home

If you want seriously host your emails at home, you will need the following:

- A static IP address from your ISP (Internet Service Provider).
- Make sure your port 25 is not blocked.
- A low power consumption hardware. See below for example.

### Host emails online

Any serious hosting platform can provide a server, virtual or physical, with an externally accessible IP address. Some
providers, however, are blocking the port 25 (e.g. Google cloud).

Be careful, using a VPS (Virtual Private Server) is no more secure than hosting at your home:

- You may not have control on the kernel installed.  This is less secure than Homebox, which is by default configured to
  run on AppArmor.
- You will not be able to use Full Disk Encryption. Although there are some security measures in places, it is still
  perfectly possible to extract data from your disk, and spy their content.
- You will not have the choice on when and which security updates are applied.  Most hosting providers have specific
  time windows to update the kernel images they use, which may not be as soon as you need, or even appropriate to you.

# Pre-installation steps

## Set up your domain name entries

The first thing you need is a domain name and a DNS provider, there are many options available.  For now, using Gandi
has some advantages.

However, here a [list of other DNS providers](https://github.com/AnalogJ/lexicon#providers) you can use.

You can use something traditional, based on your name, or something more fancy.

Once you have chosen the domain name, it is necessary to configure the associated DNS servers, and the _glue records_.

For instance, on Gandi, you will have to set up the glue records first and then the DNS servers used for your domain:

### Glue records

![Glue records](img/dns-setup/glue-records.png)

### DNS servers

![DNS servers](img/dns-setup/dns-servers.png)

## Set-up your home network

This is necessary only if you choose to use a home device to host your emails. If you are using an online server, you
can obviously skip this section.

![Network setup](img/initial/home-schema.svg)

Ideally, you will need to configure your router to redirect all the external traffic to your homebox using the "DMZ"
functionality if there is one. The other option is to redirect only the ports you will need.

Initially, the following TCP ports are required:

- To obtain your certificates from LetsEncrypt, you need your system to be accessible externally on the port 80.
- To test sending and receiving emails, your system should be accessible on the port 25 as well.
- To retrieve emails, your system should be accessible on ports 143, 993, 110, 995.
- To send emails, your system should be accessible on ports 587 and/or 465.
- For Thunderbird automatic configuration, your system should be accessible on port 80.
- Once installed, SOGo and the webmail are accessible through http (port 80), but redirects you directly to https (port
  443).

The next step is to link your domain name (e.g homebox.me) register your server, using the static IP address that has
been assigned to you. This is the topic of the next section.

## Choose the hardware

An old laptop should be enough to start, with the main advantage of being somewhat resistant to power failures.  I also
suggest you to have a look on this Debian page: [Cheap Serverbox Hardware](https://wiki.debian.org/FreedomBox/Hardware)
of the project freedombox, another excellent project.

The preseed configuration (see next step) provides an option to use software RAID, so you can use this as well if you
prefer. However, remembe that RAID is not backup!

## Prepare your workstation

Any workstation with a decent text editor like _Emacs_, _Vim_ or even _[VS code](https://code.visualstudio.com/)_ should
be enough. You will need to run the Ansible scripts, and perhaps to install rsync.

I recommend using Linux, any flavour, but for a very expensive price, MacOS should be about fine.

You will need to install ansible and rsync as well. For instance, on Debian or Ubuntu:

```sh
apt install ansible rsync ansible
```

## Build the CD image

If you already have a Debian server (Stretch) installed, and you prefer to use it, it's fine, you can skip this
section and start the [configuration](configuration.md) directly. Otherwise, keep reading.

This CD image will be used to create an automatic Debian installer more quickly than manually answering questions when
installing Debian.

The disc created does not install the mail server, only the Debian distribution. However, there are two features
automatically installed and easily configured: AppArmor and Full Disc Encryption with LUKS. Both will protect you
against remote and physical intrusion.

It is also copying your public SSH key onto the installation disc, so you can directly connect to your server remotely,
as root for now.

### 1. Create your hosts file

This file simply contains the IP address of your box. It can be on your local network or on internet.

```sh
cd config
cp hosts-example.yml hosts.yml
```

Here an example:

```yaml
all:
  hosts:
    homebox:
      ansible_host: 192.168.1.254
      ansible_user: root
      ansible_port: 22
```

The installer runs with Ansible, as the root user. Once the installation is finished, it is possible to completely
disable remote root login, and to enforce sudo usage, if this is your favourite way to go.

The detailed documentation for this step is available in the [preseed section](preseed.md).

The next step is detailed in the [configuration](configuration.md) section, and is really the installation procedure.
