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


## Custom Debian repository

Implement a personal Debian repository to publish your packages. Will handle GPG signing as well.


## Matrix server

The Debian repository includes _Synapse_, the reference implementation. See the [matrix website](https://matrix.org/)
for more details.
