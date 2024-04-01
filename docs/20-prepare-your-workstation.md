
# Prepare your workstation

## Configure SSH

Ansible uses SSH to connect on the target server, so the best is to use public key authentication. We will not detail
here the creation of your private key.

** This is now happening on the workstation, here simply called _hamilton_ **.

### Copy your public key

```plain
andre@hamilton> ssh-copy-id hbinstall@192.168.33.95
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
hbinstall@192.168.178.95's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'hbinstall@192.168.33.95'"
and check to make sure that only the key(s) you wanted were added.
```

### Test the connection

Now, the connection should be automatic, i.e. without entering a password:

```plain
andre@hamilton> ssh hbinstall@192.168.33.95
Linux debian 6.1.0-17-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.69-1 (2023-12-30) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Jan 13 10:42:02 2024 from 192.168.33.90
hbinstall@debian:~$
```

### Optional: Create connection settings in ssh

This is optional, but it will be more convenient to add ssh settings to connect on the server, instead of typing a user
name and an IP address. So, on the workstation, in your ssh configuration file `~/.ssh/config`, you can add the
following block, for instance:

```plain
Host homebox
    User hbinstall
	HostName 192.168.33.95
```

Yo can now establish the connection with _homebox_ more easily:

```plain
ssh homebox
[…]
Linux debian 6.1.0-17-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.69-1 (2023-12-30) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Jan 13 10:44:29 2024 from 192.168.33.90
```

### Install ansible and other required tools

Install Ansible, with any command of your choice. For instance, on Debian or Ubuntu:

```sh
sudo apt install ansible
```

## Clone the repository

```plain
git clone git@github.com:progmaticltd/homebox.git
Cloning into 'homebox'...
remote: Enumerating objects: 26137, done.
remote: Counting objects: 100% (875/875), done.
remote: Compressing objects: 100% (171/171), done.
remote: Total 26137 (delta 759), reused 728 (delta 703), pack-reused 25262
Receiving objects: 100% (26137/26137), 9.53 MiB | 3.72 MiB/s, done.
Resolving deltas: 100% (15687/15687), done.
```

!!! Note
    If you intend to clone multiple homebox repositories, it's a good idea to create a dedicated folder, for instance,
    called `homebox-all`.

There should be now a folder called ‘homebox’, and you'll have now to define your configuration.

## Optional: Set-up _pass_

HomeBox dynamically generate credentials, and store them on your workstation. The credentials can be stored into plain
text files, or stored using a utility called [password store](https://www.passwordstore.org/). This allows you to store
the passwords encrypted using GPG, which is more secure.

For the setup of pass on the workstation, you can follow tutorial on the page above, which is out of scope.
