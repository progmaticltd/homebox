# Check the installation

Here a few steps to follow _before_ publishing the domain on internet. If any of this step fails, jump directly to the
next section, installation troubleshooting.

All the checking are now done on the target server.

## Users list

Once the installation is finished, you should now see the users list, by running the command `getent passwd -s ldap`:

```txt
root@bochica:~# getent passwd -s ldap
frodo:x:1001:1001:Frodo Baggins:/home/users/frodo:/bin/dash
samwise:x:1002:1002:Samwise Gamgee:/home/users/samwise:/bin/dash
peregrin:x:1003:1003:Peregrin Took:/home/users/peregrin:/bin/dash
meriadoc:x:1004:1004:Meriadoc Brandybuck:/home/users/meriadoc:/bin/dash
postmaster:x:2000:2000:postmaster account:/home/users/postmaster:/bin/dash
```

## DNS status

At this time, your DNS contains all the information needed, but it is not yet "plugged" on the big wide internet...We'll
see on the next page the command to run to "plug" your system on internet.

The status of your DNS server can be seen using the `dns-status` command:

```txt
root@bochica:~# dns-status
DNS server for sweethome.box is not live.
;; resolution failed: ncache nxdomain
; negative response, fully validated
; sweethome.box.                179     IN      \-ANY   ;-$NXDOMAIN
; box. SOA ns0.centralnic.net. hostmaster.centralnic.net. 1705252800 900 1800 6048000 3600
; box. RRSIG SOA ...
; 44kend9dtc8m5troibn8vggq7dqjvtnp.box. RRSIG NSEC3 ...
; 44kend9dtc8m5troibn8vggq7dqjvtnp.box. NSEC3 1 1 0 - M1K4M0PMES14HTVF726HSLVQBFOHL3I2 NS DS RRSIG
; m1k4m0pmes14htvf726hslvqbfohl3i2.box. RRSIG NSEC3 ...
; m1k4m0pmes14htvf726hslvqbfohl3i2.box. NSEC3 1 1 0 - OV2J9819PPF66UJFCBMB33GI392HJ1O7 NS SOA RRSIG DNSKEY NSEC3PARAM
```

Once the server is live, you should see instead something like this:

```txt
DNS keys are published:
Zone                          Type Act Pub Size    Algorithm       ID   Location    Keytag
------------------------------------------------------------------------------------------
weethome.box                  ZSK  Act Pub 256     ECDSAP256SHA256 3    cryptokeys  35623
weethome.box                  KSK  Act Pub 256     ECDSAP256SHA256 1    cryptokeys  17507
weethome.box                  KSK  Act Pub 256     ECDSAP256SHA256 2    cryptokeys  41341
```

## Certificates status

Since your server is not live yet, all your certificates are signed with a temporary root certificate. Once your DNS
server is live, you will be able to recreate all the certificates, with one command.

For now, this is what you should see when typing the command `cert-status`:

```
root@bochica:~# cert-status
Domain      | Valid from                | Valid until               | Days left  | Issuer        | Full domains list                                 | Status
sweethome   | Jan 14 17:33:53 2024 GMT  | Feb 11 17:33:53 2024 GMT  | 27         | Temporary CA  | DNS:sweethome.box                                 | OK
main        | Jan 14 17:34:02 2024 GMT  | Feb 11 17:34:02 2024 GMT  | 27         | Temporary CA  | DNS:main.sweethome.box                            | OK
*           | Jan 14 17:34:11 2024 GMT  | Feb 11 17:34:11 2024 GMT  | 27         | Temporary CA  | DNS:*.sweethome.box                               | OK
ldap        | Jan 14 17:34:43 2024 GMT  | Feb 11 17:34:43 2024 GMT  | 27         | Temporary CA  | DNS:ldap.sweethome.box,DNS:bochica.sweethome.box  | OK
www         | Jan 14 17:36:11 2024 GMT  | Feb 11 17:36:11 2024 GMT  | 27         | Temporary CA  | DNS:www.sweethome.box                             | OK
mta         | Jan 14 17:37:18 2024 GMT  | Feb 11 17:37:18 2024 GMT  | 27         | Temporary CA  | DNS:mta-sts.sweethome.box                         | OK
smtp        | Jan 14 17:37:47 2024 GMT  | Feb 11 17:37:47 2024 GMT  | 27         | Temporary CA  | DNS:smtp.sweethome.box                            | OK
imap        | Jan 14 17:39:15 2024 GMT  | Feb 11 17:39:15 2024 GMT  | 27         | Temporary CA  | DNS:imap.sweethome.box                            | OK
pop         | Jan 14 17:39:29 2024 GMT  | Feb 11 17:39:29 2024 GMT  | 27         | Temporary CA  | DNS:pop3.sweethome.box                            | OK
sogo        | Jan 14 17:41:16 2024 GMT  | Feb 11 17:41:16 2024 GMT  | 27         | Temporary CA  | DNS:sogo.sweethome.box                            | OK
autoconfig  | Jan 14 17:41:50 2024 GMT  | Feb 11 17:41:50 2024 GMT  | 27         | Temporary CA  | DNS:autoconfig.sweethome.box                      | OK
root@bochica:~#
```

Now that your server is ready to use, you can publish the DNS server on internet

## The backup folder

The credentials created from the installation, should be stored in a folder named from the domain name, in the _backup_
folder. This folder is excluded from git as well:

```txt
ls -lR backup
backup:
total 8
-rw-r--r-- 1 andre andre  485 Jan 13 11:36 readme.md
drwx------ 6 andre andre 4096 Jan 14 17:42 sweethome.box

backup/sweethome.box:
total 16
drwx------ 2 andre andre 4096 Jan 14 17:42 dns
drwx------ 2 andre andre 4096 Jan 14 17:40 ldap
drwx------ 2 andre andre 4096 Jan 14 17:40 postgresql
drwx------ 2 andre andre 4096 Jan 14 17:42 user

backup/sweethome.box/dns:
total 4
-rw------- 1 andre andre 17 Jan 14 17:33 api-key

backup/sweethome.box/ldap:
total 32
-rw------- 1 andre andre 17 Jan 14 17:34 admin
-rw------- 1 andre andre 21 Jan 14 17:34 frodo
-rw------- 1 andre andre 17 Jan 14 17:34 manager
-rw------- 1 andre andre 21 Jan 14 17:34 meriadoc
-rw------- 1 andre andre 21 Jan 14 17:34 peregrin
-rw------- 1 andre andre 21 Jan 14 17:34 postmaster
-rw------- 1 andre andre 17 Jan 14 17:34 readonly
-rw------- 1 andre andre 21 Jan 14 17:34 samwise

backup/sweethome.box/postgresql:
total 4
-rw------- 1 andre andre 17 Jan 14 17:40 sogo

backup/sweethome.box/user:
total 4
-rw------- 1 andre andre 21 Jan 14 17:42 admin
```
