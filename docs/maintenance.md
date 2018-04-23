## Connecting on your server

To connect on your server, you can use SSH to administer it, like doing your packages
update.

## Adding or updating user accounts

At this date, there is no web interface or graphical user interface included to update the
add, remove or edit user accounts. Maybe a web interface will be added later.
In the mean time, here some procedures you can follow.

### Changing passwords

If you only need to change an account password, you can use the command line interface and
the passwd command via SSH.

```sh
passwd john
```

You might have to respect the password policies in place, like minimal length and complexity.

### Add or remove email aliases

Updating the email aliases for a user is very easy.

First, modify the aliases section for the user, in the system.yml configuration file:

```yaml
- uid: mike
  cn: Mike Dear
  first_name: Mike
  last_name: Dear
  mail: mike.dear@example.com
  password: 'n~wI*rhf873'
  aliases:
    - mike@homebox.space
    - mikael@homebox.space
```

Then, run the Ansible playbook called __ldap-refresh.yml__. This playbook refresh the
email aliases only, and does not touch anything else. It will also remove any email alias
previously added if it is not in the list.

### Adding a user account

The best way is to modify the users section ofyour system.yml configuration file and
to run an Ansible scripts again. The main advantage of this, is that the database will be
up to date if you need to deploy your server again.

First, add a new user in the users list:

```yaml
- uid: mike
  cn: Mike Dear
  first_name: Mike
  last_name: Dear
  mail: mike.dear@example.com
  password: 'n~wI*rhf873'
  aliases:
    - mike@homebox.space
```

Then, run the ldap and home playbooks:

```sh

ansible-playbook -v -i ../config/hosts.yml playbooks/ldap.yml
ansible-playbook -v -i ../config/hosts.yml playbooks/home.yml

```

The home playbook create the home directories for this user.

### Removing user accounts

There is not yet an Ansible script to remove a user account, this will be added soon. In
the mean time, any LDAP compliant script, like _ldapdelete_ should be enough.

## Updating the system

This can be done through SSH, like you are doing on any Debian server.

## Adding or removing components

If you have not modified the system configuration files too much, you should be able to
add components just by updating your system.yml configuration file, and running the
Ansible scripts again.

Removing components entirely is not so easy, and is not entirely supported for
now. However, you should be able to remove them using the standard Debian packaging
system, i.e. __dpkg__.

### Removing the default nginx site

The easiest way is probably to remove the site from the enabled one, and restart nginx:

```sh

rm -f /etc/nginx/sites-enabled/<your domain>
systemctl restart nginx

```

### Removing ClamAV

Because postfix is configured to filter emails through ClamAV, you will have to re-run the
Ansible scripts to install Postfix again.

1. Remove the Clamav packages
2. Update your system.yml file
3. Run the Ansible scripts again

### Removing rspamd

Because postfix is configured to filter emails through ClamAV, you will have to re-run the
Ansible scripts to install Postfix again.

1. Remove the Clamav packages
2. Update your system.yml file
3. Run the Ansible scripts again

### Removing RoundCube

The easiest way is probably to remove the site from the enabled one, and restart nginx:

```sh

dpkg -r roundcube*
rm -f /etc/nginx/sites-enabled/webmail.<your domain>
systemctl restart nginx

```

If you just want to temporarily remove the webmail, removing only the link is perhaps
better, as you will be able to reinstall it again later.

### Removing the autoconfig or autodiscover sites

The easiest way is probably to remove the site from the enabled one, and restart nginx:

For _Mozilla Thunderbird_ Autoconfig

```sh

rm -f /etc/nginx/sites-enabled/autoconfig.<your domain>
systemctl restart nginx

```
For _Microsoft Outlook_ Autodiscover

```sh

rm -f /etc/nginx/sites-enabled/autodiscover.<your domain>
systemctl restart nginx

```

## Restarting the system

If you have installed the system with the main drive encrypted using LUKS, the only
important thing you need to remember is to do this locally only. Your system, when
booting, will ask for the passphrase to decrypt the system drive.

Doing this remotely would lock you out of your system till you are physically close to it.
