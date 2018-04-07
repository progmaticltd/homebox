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
    url: dir://home/backup/homebox
    active: yes                      # The backup is currently active
    frequency: daily                 # Run the backup every day
    keep_daily: 3                    # Keep the last three days locally
  - name: router
    url: ssh://fw.office.pm:/home/backup/homebox
    active: yes                      # The backup is currently active
    frequency: daily                 # Run the backup every day
    keep_daily: 7                    # Keep the last seven days (default value)
    keep_weekly: 4                   # Keep the last four weeks (default value)
    keep_monthly: 6                  # Keep the last six months (12 by default)
  - name: nas
    url: smb://backup:giuwh97kwerr@ftp.office.pm:/home/backup/homebox
    active: yes                      # The backup is currently active
    frequency: weekly                # Run the backup every week
    keep_weekly: 4                   # Keep the last four weeks (default value)
    keep_monthly: 6                  # Keep the last six months (12 by default)
```

The locations currently supported are:

- local: local drive, useful for quick and short time backup.
- ssh: remote backup on another server through SSH.
- smb: samba share, probably on your local network.

You can have different backup frequencies, for instance daily, weekly or monthly

## Emails reporting

By default, backup jobs are run overnight, and an email is sent to the postmaster, with a summary of the backup job:

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

