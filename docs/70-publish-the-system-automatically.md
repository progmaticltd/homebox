# Publishing your domain automatically

Once your system has been installed successfully, you will need to _publish_ your DNS information, so your domain can be
reached from the internet.

## Store the api key for ansible

If you have used Gandi, the process is fairly easy, otherwise, generic explanations are provided in the next section.

First, you will need to store the API and the token in the password store, so Ansible can access it.

### For plain text passwords

For plain text passwords, use the following commands:

- handle: `JD461-GANDI`
- key: `SVIs912q5RasCmIZ9YDC1XOc`

Store the API key in the backup directory:

```sh
echo SVIs912q5RasCmIZ9YDC1XOc > backup/sweethome.box/gandi/api-key
chmod 0600 backup/sweethome.box/api-key
```

You can publish your domain using the following command

### If you are using _pass_

If you are using pass, you will need to add the token to the password database, by using this command on the
workstation:

```sh
pass insert sweethome.box/gandi/api-key
Enter password for sweethome.box/gandi/api-key: ******
Retype password for sweethome.box/gandi/api-key: ******
```

Your api key is now safely stored into _pass_.

## Run the command to publish your domain

Everything is handled through an Ansible role, with one command:

```txt
cd playbooks
ROLE=dns-publish ansible-playbook -v install.yml
```

The output should be something like this:

```txt
PLAY RECAP *************************************************************************************************************
homebox                    : ok=61   changed=0    unreachable=0    failed=0    skipped=15   rescued=0    ignored=1

Sunday 14 January 2024  19:12:29 +0000 (0:00:00.414)       0:00:12.985 ********
===============================================================================
dns-publish ------------------------------------------------------------- 6.97s
gather_facts ------------------------------------------------------------ 4.08s
common-init ------------------------------------------------------------- 1.68s
include_role ------------------------------------------------------------ 0.17s
set_fact ---------------------------------------------------------------- 0.07s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
total ------------------------------------------------------------------ 12.98s
```

If you have an access denied error, first, check your token value.

Now, wait from a few minutes to an hour, and check the dns-status again:

```sh
root@bochica ~# dns-status
DNS keys are published:
Zone                          Type Act Pub Size    Algorithm       ID   Location    Keytag
------------------------------------------------------------------------------------------
sweethome.box                 ZSK  Act Pub 256     ECDSAP256SHA256 3    cryptokeys  35623
sweethome.box                 KSK  Act Pub 256     ECDSAP256SHA256 1    cryptokeys  17507
sweethome.box                 KSK  Act Pub 256     ECDSAP256SHA256 2    cryptokeys  41341
root@bochica ~#
```
