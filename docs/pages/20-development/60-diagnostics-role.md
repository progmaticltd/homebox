# Diagnostics role

## Presentation

This is a special role useful for development and diagnostics.

First, it is installing packages useful for debugging:

- aptitude
- bash-completion
- curl
- dnsutils
- file
- htop
- jq
- less
- lnav
- locate
- man
- mc
- net-tools
- netcat-openbsd
- pfqueue
- screen
- tcpdump
- vim
- whois
- zsh

Then, default _rc_ files are created for the following packages:

- bash
- zsh
- vim
- screen

## Install

```sh
ROLE=diagnostic ansible-playbook install.yml
```

## Uninstall

```sh
ROLE=diagnostic ansible-playbook uninstall.yml
```
