# Diagnostics role

## Presentation

This is a special role useful for development and diagnostics. First, it is installing
packages useful for daily usage, development or debugging. Then, default _rc_ files are
created for the following packages:

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
