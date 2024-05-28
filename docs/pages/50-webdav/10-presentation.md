# WebDAV server

## Presentation

The WebDAV server allows your users to save personal files, but not to share them with the other users. The
authentication is done using `libpam` on nginx.


## Default settings

The default settings are minimal, and set the maximum file size the users can update.

```yml
webdav:
  max_file_size: 1G
```


## Clients

The server has been successfully tested with Linux Debian desktop, Microsoft Windows, Android.

Coupled with with [Davx5](https://www.davx5.com/) on Android, this can be used as a backup provider.


## Internals

When the system boot, a systemd service started for each user, running as the user, even if they are not logged-in. This
is done using the _systemd_ command `loginctl enable-linger`.

For more details about the implications, see the
[loginctl manual page](https://www.freedesktop.org/software/systemd/man/latest/loginctl.html).
