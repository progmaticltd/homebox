# Roadmap

These features are not implemented yet, but are currently "on the radar", depending on the developers' free time and
demand...Send your suggestion as an issue on the [GitHub site](https://github.com/progmaticltd/homebox/issues).


## Disposable email address

So you can create temporary email addresses when registering on a system. The hardest part here is to offer an interface
for the users to create and review their disposable email addresses.


## Port-knocker

The SSH server is already secure in itself, as it does not allow password authentication by default. However, adding a
port knocker will mainly reduce the noise in the server logs.

The current options are:

- A simple SSH port knocking, using TCP or UDP, implemented in _nftables_.
- Better port knocking, using fwknop "Single Packet Authentication".


## BitTorrent client

A BitTorrent client for each user, for instance using transmission service, and a secure web frontend, will allow to
save torrent files more securely. When the WebDAV server is installed as well, this will give easy access to the files,
using a computer or a phone.


## Web console access

Although there is already a role to install _cockpit_, a lot of features are not relevant or not used. There are simpler
versions of a web terminal we can install, over a secure https link.


## Custom Debian repository

Implement a personal Debian repository to publish your packages. Will handle GPG signing as well.


## Matrix server

The Debian repository includes _Synapse_, the reference implementation. See the [matrix website](https://matrix.org/)
for more details.
