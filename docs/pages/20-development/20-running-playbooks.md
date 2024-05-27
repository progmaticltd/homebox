# Running the playbooks

The _roles selection playbooks_ let you install, check, backup, restore and uninstall, a selection of one or more
roles. They are described below.

## Roles selection playbooks

### Install the simple web site

This is the simplest example:

```sh
ROLE=website-simple ansible-playbook install.yml
```

This will install a simple static web site using nginx, with the certificates automatically renewed using _LetsEncrypt_.


### Running multiple roles

The following command will install both _autoconfig_ and _autodiscover_ to the target system, two roles to pusblish
necessary information for certain email clients like _Mozilla Thunderbird_ or _Microsoft Outlook_:

```sh
ROLE=autoconfig,autodiscover ansible-playbook install.yml
```

### Running multiple playbooks

Very useful when developing. For instance, the following command will run the uninstallation, installation and
self-check tasks for the role _website-simple_ in one command only:

```sh
ROLE=website-simple ansible-playbook uninstall.yml install.yml check.yml
```

### Combining both

Installing two roles, then running the checking tasks on each of them.

```sh
ROLE=autoconfig,autodiscover ansible-playbook install.yml check.yml
```


### Main playbooks

The main playbooks, `install-version.yml` and `check-version.yml` are respectively installing and checking the version
you specify from the command line. For instance, to install and check the _small_ version:

```sh
ansible-playbook -e version=small install-version.yml checking-version.yml
```

## Other options

Marking your system as a development one.

```yml
system:
  devel: true
```

Now, when running the playbooks, the generated credentials will be shown on the console.
