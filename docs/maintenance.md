## Connecting on your server

To connect to your server, you can use SSH to administer it, like doing your packages updates.

## Adding or updating user accounts

So far, there is no web interface or graphical user interface included to add, remove or edit user accounts. Maybe a web
interface will be added later. In the mean time, here are some procedures you can follow.

### Changing passwords

If you only need to change an account password, you can use the command line interface and the passwd command via SSH.

```sh
passwd john
```

You might have to respect the password policies in place, like minimal length and complexity.

### Adding a user account

The best way is to modify the users section of your system.yml configuration file and to run an Ansible script again.
The main advantage of this, is that the database will be up to date if you need to deploy your server again.

First, add a new user in the users list:

```yaml
users:
  ...
- uid: mike
  cn: Mike Dear
  first_name: Mike
  last_name: Dear
  mail: mike.dear@example.com
  password: 'n~wI*rhf873'
  aliases:
    - mike@homebox.space
```

Then, run the dedicated playbook to update users:

```sh
cd install
export ROLE=ldap-openldap,user-setup
ansible-playbook -v -i ../config/hosts.yml playbooks/install.yml
```

The home playbook creates the home directories for this user.

### Modifying a user account

If you want to directly modify a user account specified in your LDAP settings, there is a script installed in
__/usr/local/sbin/ldap-user-edit__. With this script, you can directly modify a LDAP user account, from your system.

It is a wrapper around ldapvi, so you will be able to quicly edit any user, for instance to update an email address or
an alias, or to fix a typo in the username. This is not meant for major modifications.

!!! Warning
    Any modification made this way will not be part of a disaster recovery. You will need to reflect the change in your
    system.yml too.

### Removing user accounts

There is not yet an Ansible script to remove a user account, this will be added soon. In the mean time, any LDAP
compliant script, like _ldapdelete_ should be enough.

## Updating the system

This can be done through SSH, like you are doing on any Debian server.

## Adding or removing components

Most components can be added or removed individually, using the unit playbook, for instance:

```sh
ROLE=ejabberd ansible-playbook -l homebox install.yml
```

This will install the ejabberd XMPP server.

or

```sh
ROLE=ejabberd ansible-playbook -l homebox uninstall.yml
```

This will delete the ejabberd XMPP server.

### Removing ClamAV

Adding or removing ClamAV can be done using the following command:

```sh
ROLE=clamav ansible-playbook -l homebox install.yml
```

Or to be removed:

```sh
ROLE=clamav ansible-playbook -l homebox uninstall.yml
```


## Restarting the system when the drive is encrypted

If you have installed the system with the main drive encrypted using LUKS, you need to keep a way to decrypt your drive,
locally or remotely.

There is a role you can run, to install _dropbear_. When the system starts, a small SSH server is started, to allowing
you to decrypt the drive remotely.

Here how to install it:

```sh
ROLE=luks-remote ansible-playbook -l homebox install.yml
```

Here is an example using a command line SSH client:

```sh
andre@london:~ $ ssh root@example.net

To unlock root partition, and maybe others like swap, run `cryptroot-unlock`

BusyBox v1.22.1 (Debian 1:1.22.0-19+b3) built-in shell (ash)
Enter 'help' for a list of built-in commands.

~ # cryptroot-unlock
Please unlock disk sda5_crypt:
cryptsetup: sda5_crypt set up successfully
~ # Connection to 192.168.32.12 closed by remote host.
Connection to 192.168.32.12 closed.
```
