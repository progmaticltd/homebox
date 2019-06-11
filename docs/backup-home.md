The platform supports incremental backup of the home directory. You can specify multiple backup
strategies, and multiple locations.

The locations currently supported are:

- dir: local drive, only useful for testing; does not require another device.
- ssh: remote backup on another server through SSH (borg backup need to be installed on the remote location).
- sshfs: remote backup on another server through SSH only (does not use remote borg server).
- cifs: samba share, probably on your local network.
- usb: named USB stick / NAS drive.
- s3fs: Backup on Amazon S3.

For each location, the following procedure is followed:

1. The backup location is mounted by the system.
2. The backup is initialised if it is not existing (borg init).
3. The backup is created (borg create).
4. The backup is checked (borg check).
5. The backup location is unmounted by the system.
6. An email is sent, with the result of all the steps.
7. If Jabber is activated, an IM is sent to inform the backup is finished, with the end result.

# Backup strategy example

Here a non exhaustive example with multiple locations:

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

When needed, the locations are automatically mounted when the backup starts, and dismounted once
the backup finished.

You can have different backup frequencies, for instance daily, weekly or monthly.

# Backup locations details

For any backup type, the destination directory need to exist. All the backups are encrypted using the same encryption
key. The encryption key backup is in your [backup directory](/deployment-backup/), in encryption/backup-key.pwd

## Backup in a local directory

This can be a temporary solution unless your main homebox drive is mounted in RAID (see
[preseed](/preseed#software-raid)) or if you have mounted a remote location yourself.

```yaml
backup:
  ...
  - name: local
    url: dir://var/backups/homebox
    active: yes
    frequency: daily
    keep_daily: 7
    keep_monthly: 12
    idle_sec: 60
    check_frequency: weekly
```

## Backup over the network using SSH

This location scheme is using borg on a remote server, over SSH. Therefore, the borg software need
to be installed on the remote machine, with the appropriate permissions.

For instance, you want to backup your system on a sever accessible via backup.homebox.space, with
the user "alice":

```yaml

backup:
  ...
  - name: backup-station
    url: ssh://alice@backup.homebox.space:/home/alice/backup/homebox
    active: yes                      # The backup is currently active
    frequency: daily                 # Run the backup every day
    keep_daily: 7                    # Keep the last seven days (1 by default)
    keep_weekly: 4                   # Keep the last four weeks (1 by default)
    compression: lz4                 # Use the fast compression for daily backups
```

For SSH backup, the authentication scheme used is public key authentication, i.e. no password.

The Ansible installation script automatically create a private and a public key for the root user,
and send the public key to the postmaster, by email. You need to copy the key to the desired
location on the remote instance, and configure your `authorized_keys` roughly like this:

``` sh
# backup from homebox
command="borg serve --restrict-to-path /home/alice/backup",restrict ssh-rsa AAAAE2VjZHN…SZzah5h5U+m4MJumCRRCJQXxaQ== backup@homebox
```

The private and public keys are also saved in the deployment backup folder, into ssh-keys/root.

## Backup over the network using SSHFS

This location scheme allows you to backup on a remote system over SSH, wihtout borg being
installed. Here an example on an internal router:

```yaml
backup:
  ...
  - name: router
    automount: true
    url: sshfs://backup@bkp.router.lan:/var/backup/homebox
    keyName: backup.ecdsa
    active: yes
    frequency: daily
    keep_weekly: 4
    keep_monthly: 6

```

The key name will be used to configure SSH to connect with this key, in the ~/.ssh/config.d/backup-router

```txt
# SSH configuration for router
Host bkp.router.lan
  User backup
  UserKnownHostsFile /dev/null
  CheckHostIP no
  StrictHostKeyChecking no
  IdentityFile ~/.ssh/backup.ecdsa
```

## Backup on a USB drive

This is the recommended way to backup your system when you are restrained to local backup. Here
an example:

```yaml
backup
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

The filesystem UUID should be specified, and the initial folder should already exist on the
external device. To obtain the UUID of your external drive, use blkid command. You do not need to
be root. For instance:

```sh
$ /sbin/blkid /dev/sdb1
/dev/sdb1: LABEL="PortableBackup" UUID="6d83f6d4-2769-46d0-b07b-675ab0863393" TYPE="ext4" PARTLABEL="PortableBackup" PARTUUID="01572f1c-bb90-4eda-bccf-6e5953a25f44"

```

Once the backup is finished, the USB drive be automatically unmounted after 60 seconds of
inactivity. This allows you to remove the usb drive safely.

## Backup on a network drive

You can also backup on a network drive, perhaps on your local network, using SMB protocol (Windows
network share). Here an example:

```yaml
backup:
  ...
  - name: home.lan
    url: cifs://backup:eecPxKbeDvs02g7BEdwf@nas1.home.lan:/backup
    active: yes
    frequency: weekly
    keep_weekly: 4
    keep_monthly: 6
```

## Backup on Amazon S3

You can also backup on a S3 bucket on AWS cloud platform. Here an example:

```yaml
backup:
  ...
  - name: s3main
    automount: true
    url: s3fs://mnt/backup/s3main/homebox
    active: yes
    frequency: weekly
    keep_weekly: 4
    keep_monthly: 6
    access_key_id: AKD1WAGJDIKWSX2TRPQR
    secret_access_key: gBiRu5hPSyswK17TNpp2IIf5sWDNJx6Vb9Gx3rjF
    bucket_name: homebox-backup.example.com
    region: eu-west-2
```

And here an appropriate example of bucket policy:

```json
{
    "Version": "2012-10-17",
    "Id": "Policy1559913732504",
    "Statement": [
        {
            "Sid": "Stmt1559913723346",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::399724661369:user/homebox"
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::homebox-backup.example.com"
        }
    ]
}
```

You can use the [Amazon S3 policy generator](https://awspolicygen.s3.amazonaws.com/policygen.html).

As usual, everything is encrypted locally using borg backup. Therefore, no one will be able to
decrypt your files without the encryption key.

**Notes**

- This location storage is actually under scrutiny, and might be removed if proven unstable.
- Under the hood, [S3FS](https://github.com/s3fs-fuse/s3fs-fuse) is used, with the cache option activated, and located
  in /home/.backup-cache/. Because this folder content is about the size if the whole backup, the /home partition should
  have enough available disk space.

# Backup contents

At this time, only the content of the /home folders is back up, perhaps the emails. This should also allow you to
restore your emails after a fresh installation or in case of accidental deletion.

Any file stored by the users in their home folders is back up too.

Some folders are excluded from the backup, like the email indexes and temporary files.

## Notes

- If [Gogs](/gogs-configuration/) is installed, the repository files are automatically excluded from backup.
- If the Transmission bittorrent daemon is installed, the downloaded files are excluded as well.

# Emails reporting

By default, backup jobs are run overnight, and an email is sent to the postmaster, with a summary of the backup job:

## Example of backup success email

``` html

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
——————————————————————————————————————————————————————————————————————————————
Prune status:
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
Deleted data:                    0 B                  0 B                  0 B
All archives:              784.84 MB            617.59 MB            123.94 MB

                       Unique chunks         Total chunks
Chunk index:                    2014                13830
------------------------------------------------------------------------------
terminating with success status, rc 0
——————————————————————————————————————————————————————————————————————————————
Check status:
Starting repository check
Starting repository index check
Completed repository check, no problems found.
Starting archive consistency check...
Analyzing archive home-2019-06-04 15:10:43.524553 (1/10)
Analyzing archive home-2019-06-04 17:42:15.409853 (2/10)
Analyzing archive home-2019-06-04 17:56:40.781983 (3/10)
Analyzing archive home-2019-06-04 18:01:27.745755 (4/10)
Analyzing archive home-2019-06-04 18:08:36.704945 (5/10)
Analyzing archive home-2019-06-05 06:25:04.664133 (6/10)
Analyzing archive home-2019-06-06T06:25:06 (7/10)
Analyzing archive home-2019-06-07T08:01:36 (8/10)
Analyzing archive home-2019-06-08T06:25:05 (9/10)
Analyzing archive home-2019-06-08T15:50:29 (10/10)
Archive consistency check complete, no problems found.
```


## Example of backup success but prune error email

``` html

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
——————————————————————————————————————————————————————————————————————————————
Prune errors:
At least one of the "keep-within", "keep-last", "keep-hourly", "keep-daily", "keep-weekly", "keep-monthly" or "keep-yearly" settings must be specified.
terminating with error status, rc 2

```

# Send reports using Jabber.

Homebox comes with the option to send backup status using short messages in real time, using the
Jabber server embedded in the platform. To do so, use the following settings:

```yaml
backup:
  install: true
  type: borgbackup
  alerts:
    jabber: true
    from: postmaster@homebox.space
    recipient: andre@homebox.space
  locations:
  ...
```

A first message will be sent just before the backup process starts, and onother one once the
process is finished, with the status. The last message contains only the status. For a full
report, you'll still have to check the email.

## Example of success message sent by Jabber

```html
00:00 postmaster: Starting backup process for location "nas1"
00:15 postmaster: Backup process finished successfully for location "nas1"
```

## Example of error message sent by Jabber

```html
00:00 postmaster: Starting backup process for location "nas1"
00:03 postmaster: Backup process failed for location 'nas1' (See the email for details)
```
