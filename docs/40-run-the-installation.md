# Run the installation

Now, the serious things starts.

## Default installation

The first - and hopefully only needed task is too run the playbook for the version you chose. This can be done with the
following command:

```sh
cd playbooks
ansible-playbook -e version=<version you choose> install-version.yml
```

For instance, for the _large_ version:

```sh
cd playbooks
ansible-playbook -e version=large install-version.yml
```

If you don't specify the version, by default, the `small` version will be installed.

```sh
cd playbooks
ansible-playbook install-version.yml
```

Once the installation is finished, you should see a final output like this:

```txt
...

PLAY RECAP *************************************************************************************************************
homebox                    : ok=1415 changed=373  unreachable=0    failed=0    skipped=453  rescued=0    ignored=16

Sunday 14 January 2024  17:42:27 +0000 (0:00:00.413)       0:10:51.372 ********
===============================================================================
certificates ---------------------------------------------------------- 187.88s
dovecot ---------------------------------------------------------------- 83.89s
bootstrap -------------------------------------------------------------- 83.60s
sogo ------------------------------------------------------------------- 49.13s
postfix ---------------------------------------------------------------- 42.17s
ldap-openldap ---------------------------------------------------------- 35.66s
nginx ------------------------------------------------------------------ 30.74s
user-setup ------------------------------------------------------------- 29.96s
dns-record ------------------------------------------------------------- 21.58s
dns-pdns --------------------------------------------------------------- 14.96s
opendmarc -------------------------------------------------------------- 14.93s
opendkim --------------------------------------------------------------- 12.67s
firewall --------------------------------------------------------------- 12.48s
post-install ------------------------------------------------------------ 9.07s
website-simple ---------------------------------------------------------- 7.15s
autoconfig -------------------------------------------------------------- 6.67s
mta-sts ----------------------------------------------------------------- 3.72s
gather_facts ------------------------------------------------------------ 1.78s
include_role ------------------------------------------------------------ 1.75s
common-init ------------------------------------------------------------- 1.50s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```
