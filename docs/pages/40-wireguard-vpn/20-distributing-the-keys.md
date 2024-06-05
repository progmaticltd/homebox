# Distributing the keys

## Configuration files

After the installation, the configuration files, the private and public keys, and QR codes
are automatically saved in the user's archives folder, using the following structure:

`/home/archives/<user>/files/vpn/<vpn-name>/<config-file>`

| Filename       | Description                           |
|----------------|---------------------------------------|
| pre-shared-key | pre-shared key for extra security     |
| private-key    | private key                           |
| public-key     | public key                            |
| qrcode.asc     | qrcode to be displayed on a terminal  |
| qrcode.png     | qrcode to be displayed on the desktop |
| user.conf      | configuration for the `wg-quick` tool |

### Using the WebDAV server

If the webdav role is installed, this is the easiest solution, and does not require any
administrative work.

In this case, the files can be copied on a desktop computer or a phone directly.

It may be also possible to send the keys by email, albeit it is probably less secure.
