# Introduction

This section will explain all the necessary steps _before_ the installation really starts, like the DNS records or your
home network set-up.

It is not a “Self hosting for newbies”, but if you follow the instructions carefully, you do not need strong technical
knowledge to achieve the above.

You still need some basic understanding though, like what is an IP address or a port, how to run Ansible in a console,
how to edit Yaml files, etc.


## Hosting emails at home

If you want to seriously host your emails at home, you will need the following:

- A static IP address from your ISP (Internet Service Provider).
- Make sure your port 25 is not blocked.
- A low power consumption hardware.

Pros:

- Better privacy,
- Cheaper if you already pay for broadband with a static IP address.

Cons:

- Your internet connection and electric providers need to be stable.
- Might be cumbersome when you are moving.
- This is not _digital worker_ friendly.


## Hosting emails online

Any serious hosting platform can provide a server, virtual or physical, with an externally accessible IP address. Some
providers, however, are blocking the port 25 (e.g. Google cloud).

Pros:

- Does not rely on the reliability of your internet connection or your electricity provider.
- Easier to manage remotely, especially for _digital workers_.

Cons:

- You may not have control on the kernel installed or the options available.
- You may not be able to use Full Disk Encryption. Although there are some security measures in places, it is still
  perfectly possible to extract data from your disk without your knowledge or consent.


# Pre-installation steps

## Set up your domain name

If you are not familiar with DNS, I recommend to use Gandi and to create an API key. The playbook will handle the DNS
settings itself.

Otherwise, here is a [list of other DNS providers](https://github.com/AnalogJ/lexicon#providers) you can use.

In this case, it is necessary to configure the associated DNS servers, and the _glue records_.

## Home based: set-up your home network

This is necessary only if you choose to use a home device to host your emails. If you are using an online server, you
can skip this section.

![Network setup](img/initial/home-schema.svg)

Ideally, you will need to configure your router to redirect all the external traffic to your homebox using the "DMZ"
functionality if there is one. The other option is to redirect only the ports you will need.

Initially, the following TCP ports are required:

- To obtain your certificates from LetsEncrypt, the port 53 in UDP and TCP mode.
- To test sending and receiving emails, your system should be accessible on the port 25 as well.
- To retrieve emails, your system should be accessible on ports 993 and 995 if you are using POP3.
- To send emails, your system should be accessible on ports 587 and/or 465.
- Once installed, SOGo is accessible through https (port 443).

The next step is to link your domain name (e.g homebox.me) to your static IP address that has been assigned to you by
your ISP.

## Prepare your workstation

Any workstation with a decent text editor like _Emacs_, _Vim_ or even Gedit should be enough. You will need to run the
Ansible scripts, and perhaps to install some packages, like rsync. I recommend using Linux, any flavour. For instance,
on Debian or Ubuntu:

``` sh
$ sudo apt install ansible rsync
```

If you already have a Debian server (Bullseye) installed, and you prefer to use it, it's fine, you can skip the next
section and start the [installation](installation.md) directly. Otherwise, click on next to read the OS installation
page.
