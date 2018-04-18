# Incremental backup

The platform supports incremental backup of the home directory.
You can specify multiple backup strategies, and multiple locations:

## Backup strategy example
```yaml

backup:
  install: true
  type: borgbackup
  locations:
  - name: local
    url: dir:///var/backups/homebox
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

- local: local drive, useful for quick and short time backup.
- ssh: remote backup on another server through SSH.
- smb: samba share, probably on your local network.

Planned / Envisaged:

- s3: backup on Amazon S3 storage
- usb: backup on USB stick when the server is at home

You can have different backup frequencies, for instance daily, weekly or monthly.

## Emails reporting

By default, backup jobs are run overnight, and an email is sent to the postmaster, with a summary of the backup job:

### Example of backup success email

```
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
```
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
