# User git server

Because not every git project has to be hosted on the big cloud providers, you can create a personal git
server for each user. This is very useful for small personal projects, dot files (e.g. .bashrc, etc.) or
text files backups.

- Repositories are accessed over SSH only, no web front-end.
- Git repositories are automatically created on first push.
- Repository names are validated.
- Repositories are stored in `/home/archives/$USER/git/repositories`.
- Directory and files are only readable and writable by the original user.
- SSH certificates and configuration files dynamically generated and sent by email.


## Configuration

Specify each users’ ssh  keys information, like this:

```yml
users:
  [...]
  - uid: frodo
    cn: Frodo Baggins
    first_name: Frodo
    last_name: Baggins
    mail: frodo.baggins@{{ network.domain }}
    aliases:
      - frodo@{{ network.domain }}
    ssh:
      - comment: git-202405
        type: ecdsa-sha2-nistp256
        data: >-
          AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIYV5u9JvjgjBDYgwT
          WqsV1R0iNFL81kwAmbQAjo6fiIdwcEWPp7N4mOvl1bPltwLPrMgLtMWtGK3Rg3LPWafCM=
        usage: git
```

!!! Note
    Make sure to add _git_ the _usage_ for each key, to ensure the proper key generated.

```sh
ROLE=user-git-server ansible-playbook install.yml
```

Once installed, the following will be set:

- A new group called _git-users_ will be created.
- Each user accounts with an SSH key, with the usage set to `git` will be added to the _git-users_ group.

Finally, for each user in the _git-users_ group:

- A repository directory will be created, in `/home/archives/<uid>/git/repositories/`.
- The public key specified will be signed and a certificate will be created.
- The certificate will restrict the ssh key to one command only, `/usr/local/bin/git-only`.
- All the keys, certificates and ssh configuration files will be stored in the backup directory,
- The same files will be sent by email for each user.

Without any parameter, the git-command will be run with a small help:

```sh
ssh git.arda.world

PTY allocation request failed on channel 0
Your key can only be used for git
---
This script allow git access to user repositories.
Git repositories are automatically created on first push.
Valid repository names should start with a letter, followed
by alphanumeric or hyphen, underscore and dot characters
Repositories are stored in /home/archives by default.

Example of repository creation:
$ git remote add personal git.arda.world:repo-name.git
$ git push --all --tags personal

To list your repositories:
ssh git.arda.world repo list
---
Connection to middle-earth.arda.world closed.
```


## Simple usage

To use the git server, the users will be able to add another remote. For instance, for a repository called "dot-files,
for a domain "arda.world" :

```sh
git checkout main
git remote add personal 'git.arda.world:dotfiles.git'
git push -u personal main
```
And to list the repositories:

```sh
ssh git.arda.world repo list

Repositories list
Repository         | Size | Accessed            | Modified
---                | ---  | ---                 | ---
dotfiles.git       | 364K | 2024-05-26 06:35:57 | 2024-05-26 06:35:57
manuscript.git     | 15M  | 2024-05-23 11:52:55 | 2024-05-23 11:53:08
homebox.git        | 11M  | 2024-05-20 17:56:10 | 2024-05-20 18:02:28
book.git           | 200K | 2024-05-07 07:22:04 | 2024-05-07 07:22:04
ansible-gpg.git    | 144K | 2024-05-06 19:52:26 | 2024-05-06 19:52:26
homebox-site.git   | 8.4M | 2024-05-06 14:48:53 | 2024-05-06 14:48:53
```


## Checking the installation

Once installed, you can check if the installation has been successful with the command below.


```sh
ROLE=user-git-server ansible-playbook check.yml
```

It will display the server certificate and the administration key, if you chose to use one:

```plain
[...]

TASK [user-git-server : Load the users details] ********************************
ok: [homebox]

TASK [user-git-server : Store the user UID number] *****************************
ok: [homebox]

TASK [user-git-server : Check that the user has repositories defined] **********
ok: [homebox]

TASK [user-git-server : Ensure the git folder exists] **************************
ok: [homebox] => changed=false
  msg: All assertions passed
```


## Uninstalling

Like any other role, you can uninstall the user git functionality, using the following command:


```sh
ROLE=user-git-server ansible-playbook uninstall.yml
```

!!! Note
    Only the server settings and the generated keys are deleted. For safety reasons, the repositories are left in
    place. If you want to delete them, this need to be done by the administration account, for now.
