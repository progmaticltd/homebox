
## OpenPGP Web Key Directory

You can publish your users’ PGP public keys as a [Web Key Directory](https://tools.ietf.org/html/draft-koch-openpgp-webkey-service).

Mail clients should locate PGP public keys automatically using this scheme, as well as [GnuPG doing it by default since
version 2.1.23](https://wiki.gnupg.org/WKD#Implementations).

The public keys are published according to both the direct and advanced methods: the advanced method is recommended; the
direct method might be needed to support the first clients that implemented the RFC draft.

To deploy the Web Key Directory, the public keys are expected to be in the server configuration in a “pgp_public_keys”
object list along with the user’s _uid_.

```
pgp_public_keys:
  - uid: andre
    public_key: |-
      -----BEGIN PGP PUBLIC KEY BLOCK-----

      […]
      -----END PGP PUBLIC KEY BLOCK-----
```

This `pgp_public_keys` list is separate from the `users` list to be able to put it at the end of the configuration file,
the PGP public keys being a bit larger than SSH public keys.
