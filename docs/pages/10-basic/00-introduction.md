# Introduction

HomeBox is a solution to transform a standard Linux Debian server into a fully configured
system to store your personal information. These include emails and instant messages,
calendars and contacts, as well as personal files. It is perfect for a family or a small
to medium community, private or professional.

The nitty-gritty features are implemented, freeing you from the major "free" platforms
that sells your data to third party companies.

By choice, HomeBox does not offer an easy to use, web based installation wizard, neither a
simple script to download and execute on your system. Other solutions are offering this
approach, and you'll find some links at the end of this page.

Instead, HomeBox is using _Ansible_, a provisioning tool, to deploy and configure all the
software needed. The principle is to describe your configuration in a very simple text
file, and to deploy the system from it. This approach has pros and cons, described below.


## Pros

- Everything is done using the standard Linux commands over SSH, a very secure
  communication protocol.
- It does not requires a custom web server opened on internet, to configure your system.
- Because the core services of the Linux distribution are not altered, everything from
  Debian still works: Security updates, other packages installation, standard commands,
  etc.
- For the same reason, you can get support from the huge Debian community.
- Finally, from the same text file, you can reinstall the system from scratch if something
  went wrong. This concept is called _Infrastructure as code_.


## Cons

- It requires a Linux system to run Ansible. Of course, you can use Windows WSL, or MacOS.
- Typing commands into a terminal, even simple ones, can be intimidating for a neophyte.
- Conversely, adding or removing a user need to be done from the command line.


## What you need

1. A target system to install, running Debian _Bookworm_. It is better if the system is
   freshly installed, i.e. without any customisations. This could be a physical server, an
   online VPS server, or even a virtual machine for development.
2. A workstation to run Ansible. The installation has been tested with Debian Bookworm as
   well, but you can use Ubuntu, RedHat, etc...
3. A domain name, hosted on [Gandi](https://gandi.net/) or anywhere else. If you chose to
   host your domain on Gandi, you can use an API to update specific DNS settings.
4. A budget. A server and an internet connection is not free, neither a custom
   domain. However, with time, you'll see the advantages of self-hosting are largely worth
   the cost. A minimal budget starts at 35 $/€/£ per year, domain included.


## What's next

Once you have everything, you'll need to:

- Prepare the target system.
- Prepare the workstation to deploy the system.
- Define your configuration.
- Run the installation.
- Run the post-installation tasks.

All these steps are described in details on the next pages.
