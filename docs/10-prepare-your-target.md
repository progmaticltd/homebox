# Prepare the target system

This section describes the process from a freshly installed Debian distribution, without any user. You can go to the
next section if your system already have a dedicated user with an SSH connection and root access.

It is relevant whatever you are using a live system or a virtual machine for development.


## Create an installation user

**Everything described here happens on the remote server, here just called "debian"**

This section creates a user dedicated for the installation, that will be removed later. You can skip it in the following
cases:

1. You already have a user with sudo access, allowed to connect over SSH, or
2. You want to use the root account to connect on your server over SSH.

In our case, we'll create a temporary user, called for instance `hbinstall`, for HomeBox install, and give them a random
password:

```plain
root@debian:~# adduser hbinstall
Adding user `hbinstall' ...
Adding new group `hbinstall' (1000) ...
Adding new user `hbinstall' (1000) with group `hbinstall (1000)' ...
Creating home directory `/home/hbinstall' ...
Copying files from `/etc/skel' ...
New password:
Retype new password:
passwd: password updated successfully
Changing the user information for hbinstall
Enter the new value, or press ENTER for the default
        Full Name []: homebox install
        Room Number []:
        Work Phone []:
        Home Phone []:
        Other []:
Is the information correct? [Y/n]
Adding new user `hbinstall' to supplemental / extra groups `users' ...
Adding user `hbinstall' to group `users' ...
```

Now, let's install _sudo_,...

```plain
root@debian:~# apt install sudo
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  sudo
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 1,889 kB of archives.
After this operation, 6,199 kB of additional disk space will be used.
Get:1 http://deb.debian.org/debian bookworm/main amd64 sudo amd64 1.9.13p3-1+deb12u1 [1,889 kB]
Fetched 1,889 kB in 1s (3,680 kB/s)
Selecting previously unselected package sudo.
(Reading database ... 33327 files and directories currently installed.)
Preparing to unpack .../sudo_1.9.13p3-1+deb12u1_amd64.deb ...
Unpacking sudo (1.9.13p3-1+deb12u1) ...
Setting up sudo (1.9.13p3-1+deb12u1) ...
Processing triggers for man-db (2.11.2-2) ...
Processing triggers for libc-bin (2.36-9+deb12u3) ...
```

..., and add the new user to the sudo and root groups:

```plain
root@debian:~# adduser hbinstall sudo
Adding user `hbinstall' to group `sudo' ...
Done.
root@debian:~# adduser hbinstall root
Adding user `hbinstall' to group `root' ...
Done.
```

Finally, we need to grant the `hbinstall` user to run any command without using password:

```sh
echo 'hbinstall ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/hbinstall
```

Now, the user hbinstall has administrative access on the system. The next step will let the user connect over ssh
without interaction.

In order for the system to run ansible commands, two packages need to be installed, if not already installed:

```sh
apt install python3 python3-apt
```
