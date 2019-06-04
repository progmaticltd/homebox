# Incremental backup

The platform supports incremental backup of the home directory.
You can specify multiple backup strategies, and multiple locations:

## Backup strategy example

```yaml

backup:
  install: true
  type: borgbackup
  locations:
  - name: nas1
    automount: true
    uuid: 6e2cd39d-1109-43de-aee5-a6491fdec689
    url: usb:///mnt/backup/nas1/homebox
    active: yes                      # The backup is currently active
    frequency: daily                 # Run the backup every day
    keep_daily: 3                    # Keep the last three days locally
    compression: lz4                 # Use the fast compression for daily backups
  - name: backup-station
    url: ssh://backup-station.office.pm:/home/backup/homebox
    active: yes                      # The backup is currently active
    frequency: daily                 # Run the backup every day
    keep_daily: 7                    # Keep the last seven days (1 by default)
    keep_weekly: 4                   # Keep the last four weeks (1 by default)
    keep_monthly: 6                  # Keep the last six months (1 by default)
    compression: lz4                 # Use the fast compression for daily backups
  - name: nas
    url: smb://backup:giuwh97kwerr@nas1:/home/backup/homebox
    active: yes                      # The backup is currently active
    frequency: weekly                # Run the backup every week
    keep_weekly: 4                   # Keep the last four weeks (1 by default)
    keep_monthly: 6                  # Keep the last six months (1 by default)
    compression: zlib,9              # Use the good but slow compression for weekly backups
```

The locations currently supported are:

- dir: local drive, useful for quick and short time backup.
- ssh: remote backup on another server through SSH.
- smb: samba share, probably on your local network.
- usb: named USB stick automatically mounted upon backup.

You can have different backup frequencies, for instance daily, weekly or monthly.

## Backup locations

For any backup type, the final destination need to be created first.

All the backups are encrypted using the same encryption key, for each device.

### Backup over the network using SSH

For SSH backup, the authentication scheme used is public key authentication, i.e. no password.

If you have one SSH backup set, the script creates a private/public key for the root user,
and send the public key to the postmaster, by email. You need to copy the key to the
desired location.

The private and public keys are also saved in the deployment backup folder.

### Backup on a USB drive

This is the recommended way to backup your system when you are restrained to local backup.

To backup on a USB drive, just use the following syntax:

```yaml
...
  - name: nas1
    automount: true
    uuid: 6d83f6d4-2769-46d0-b07b-675ab0863393
    url: usb:///mnt/backup/nas1/homebox-backup
    active: yes                      # The backup is currently active
    frequency: daily                 # Run the backup every day
    keep_daily: 3                    # Keep the last three days locally
    compression: lz4                 # Use the fast compression for daily backups
```

The exact syntax for the url takes one drive name and an optional directory name. You can have
multiple backups on the same device, by using a different sub-directory:

`url: usb:///mnt/backup/<drive-name>[/sub-directory]`

When you are setting "automount" to true, systemd services are created to automatically mount the
filesystem on demand, and to umount it after one minute of inactivity. In this case, the
filesystem UUID should be specified, and the initial folder should already exist on the external
device.

To obtain the UUID of your external drive, use blkid command. You do not need to be root. For
instance:

```sh
$ /sbin/blkid /dev/sdb1
/dev/sdb1: LABEL="PortableBackup" UUID="6d83f6d4-2769-46d0-b07b-675ab0863393" TYPE="ext4" PARTLABEL="PortableBackup" PARTUUID="01572f1c-bb90-4eda-bccf-6e5953a25f44"

```

Once the backup is finished, the USB drive be automatically unmounted after 60 seconds. This
allows you to remove the usb drive safely.

## Backup contents

At this time, only the content of the /home folders is backed up, perhaps the emails. This should
allow you to restore your emails after a fresh installation or in case of accidental deletion.

Any file stored by the users in their home folders is backed up too.

Some folders are excluded from the backup, like the email indexes and temporary files.

### Notes

- If Gogs repository is installed, the files are excluded from backup
- If the Transmission bittorrent daemon is installed, the downloaded files are excluded as well.

## Emails reporting

By default, backup jobs are run overnight, and an email is sent to the postmaster, with a
summary of the backup job:

### Example of backup success email

```html

Backup report for nas1: Success
Creation status:
------------------------------------------------------------------------------
Archive name: home-2018-04-07 22:03:47.380483
Archive fingerprint: b5ca1c8ff733e6450c861ac66ccc70fcdcffe13690a969c895bc8cf843f27059
Time (start): Sat, 2018-04-07 22:03:48
Time (end):   Sat, 2018-04-07 22:03:48
Duration: 0.37 seconds
Number of files: 2825
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
This archive:              157.00 MB            123.53 MB             58.16 kB
All archives:              784.84 MB            617.59 MB            123.94 MB

                       Unique chunks         Total chunks
Chunk index:                    2014                13830
------------------------------------------------------------------------------
terminating with success status, rc 0
Prune status:
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
Deleted data:                    0 B                  0 B                  0 B
All archives:              784.84 MB            617.59 MB            123.94 MB

                       Unique chunks         Total chunks
Chunk index:                    2014                13830
------------------------------------------------------------------------------
terminating with success status, rc 0
```

### Example of backup success but prune error email

```html

Backup report for router: Error
Exception when running backup, see logs for details
Creation status:
Synchronizing chunks cache...
Archives: 1, w/ cached Idx: 0, w/ outdated Idx: 0, w/o cached Idx: 1.
Fetching and building archive index for home-2018-04-07 13:49:40.582441 ...
Merging into master chunks index ...
Done.
------------------------------------------------------------------------------
Archive name: home-2018-04-08 07:35:51.274554
Archive fingerprint: 710bf94819fc6699cc04c050ba324541b40ef4849ed8e76603b5f0b816f1a75d
Time (start): Sun, 2018-04-08 07:35:51
Time (end):   Sun, 2018-04-08 07:35:51
Duration: 0.08 seconds
Number of files: 52
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
This archive:               62.28 kB             37.01 kB             31.88 kB
All archives:              273.41 MB            241.18 MB            241.06 MB

                       Unique chunks         Total chunks
Chunk index:                    2056                 2834
------------------------------------------------------------------------------
terminating with success status, rc 0
Prune errors:
At least one of the "keep-within", "keep-last", "keep-hourly", "keep-daily", "keep-weekly", "keep-monthly" or "keep-yearly" settings must be specified.
terminating with error status, rc 2
```

## Send reports using Jabber.

Homebox comes with the option to send backup status using short messages in real time, using the
Jabber server embedded in the platform. To do so, use the following settings:

```yaml

backup:
  install: true
  type: borgbackup
→ alerts:
    from: postmaster@homebox.space
    recipient: andre@homebox.space
    jabber: true
  locations:
  ...
```

A first message will be sent just before the backup process starts, and onother one once the
process is finished, with the status. The last message contains only the status. For a full
report, you'll still have to check the email.

### Example of success message sent by Jabber

```html
00:00 postmaster: Starting backup process for location "nas1"
00:15 postmaster: Backup process finished successfully for location "nas1"
```

### Example of error message sent by Jabber

```html
00:00 postmaster: Starting backup process for location "nas1"
00:03 postmaster: Backup process failed for location 'nas1' (See the email for details)
```
