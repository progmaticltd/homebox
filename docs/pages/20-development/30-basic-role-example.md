# Basic role example

In this example, we will create a new role called _ssh-email-alert_ that will send an
email to the first user every time the root account logs in on using SSH:

Copy the role template in the roles directory:

```sh
cp -pr devel/role-templates/basic/ roles/ssh-email-alert
```


## Write the alert script

Save the following script into `roles/ssh-email-alert/files/root-ssh-rc.sh`:

```sh
#!/bin/sh
client=$(echo "$SSH_CLIENT" -f 1 -d " ")
subject="New SSH connection from $client"
recipient=$(getent -s ldap passwd | head -n 1 | cut -f 1 -d ":")
env | mail -s "$subject" "$recipient"
```


## Write the install tasks

Here an example for the installation tasks, to be saved into
`roles/ssh-email-alert/tasks/install/main.yml`

```yml
- name: Deploy ssh rc for root
  ansible.builtin.copy:
    src: root-ssh-rc.sh
    dest: /root/.ssh/rc
    validate: dash -n '%s'
    mode: '0600'
    owner: root
    group: root
```


## Write the uninstall tasks

Here an example for the uninstall tasks, to be saved into
`roles/ssh-email-alert/tasks/uninstall/main.yml`:

```yml
- name: Deploy ssh rc for root
  ansible.builtin.file:
    path: /root/.ssh/rc
    state: absent
```

In our case, the uninstall tasks are very simple. In more complex cases, you need to
remove log files, use the _purge_ flag when removing a package, etc.

Uninstall tasks are also useful when developing, to ensure a role can be re-installed from
scratch.


## Write the self-check tasks

These tasks will be run to check the validity of the role _once installed_, they need to
be saved into `roles/ssh-email-alert/tasks/check/main.yml`

```yml
- name: Check that the rc file has no issue
  ansible.builtin.shell: dash -n /root/.ssh/rc
  changed_when: false
```

If the script contains an error, this task will fails.


## Run the install task

```sh
cd playbooks
ROLE=ssh-email-alert ansible-playbook install.yml
```

Once logged in, the first user should receive an email if the root account logs-in, with
the current environment variables, and the origin IP in the email subject.


## Run the checking task

```sh
cd playbooks
ROLE=ssh-email-alert ansible-playbook check.yml
```


## Run the uninstall task

```sh
cd playbooks
ROLE=ssh-email-alert ansible-playbook uninstall.yml
```
