# Backup and restore

The role supports backup and restore tasks, which can be useful to publish your site as well.

!!! Note
    Like most backup and restore tasks, you will required _rsync_ is installed on your local system.

## Backup the site content

```sh
cd playbooks
ROLE=website-simple ansible-playbook backup.yml
```

The site should be in your backup folder.

## Restore the site content

```sh
cd playbooks
ROLE=website-simple ansible-playbook restore.yml
```
