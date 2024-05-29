# Retrieving public keys

The keys can be retrieved by compatible clients, for instance, using emails clients like Mozilla Thunderbird or
Microsoft Outlook. Here an example with the `gpg` command line:

```plain
samwise@middle-earth:~# gpg -v --locate-external-keys frodo@baggins.me
gpg: using pgp trust model
gpg: pub  ed25519/9C3020259A5BC424 2024-04-09  Frodo Baggins <frodo@baggins.me>
gpg: key 9C3020259A5BC424: public key "Frodo Baggins <frodo@baggins.me>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: auto-key-locate found fingerprint A99502596F6AA59C302BC424C527873C7B797E10
gpg: automatically retrieved 'frodo@baggins.me' via WKD
pub   ed25519 2024-04-09 [C]
      A99502596F6AA59C302BC424C527873C7B797E10
uid           [ unknown] Frodo Baggins <frodo@baggins.me>
sub   ed25519 2024-11-12 [S] [expires: 2026-11-12]
sub   cv25519 2024-11-12 [E] [expires: 2026-11-12]
sub   ed25519 2024-11-12 [A] [expires: 2026-11-12]
```

We can see the import from they key directory, from the line `automatically retrieved 'frodo@baggins.me' via WKD`.
