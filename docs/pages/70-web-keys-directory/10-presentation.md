# Presentation

The web keys directory allows you to publish your [GPG keys](https://wiki.gnupg.org/WKD
"Gnu Privacy Guard") public key automatically, making the key easily reachable by anyone
wanting to contact you.

## Keys definition

At this time, keys are defined in the `system.yml` file, in a list called
`pgp_public_keys`, using this syntax:

```yaml
pgp_public_keys:
  - uid: frodo
    public_key: |-
      -----BEGIN PGP PUBLIC KEY BLOCK-----

      mDMEZhTZMRYJKwYBBAHaRw8BAQdAely8BVhXUC5uPtH7145/l35D04apfWqA2++J
      OuKOa7i0HkFuZHJlIFJvZGllciA8YW5kcmVAcm9kaWVyLm1lPoiOBBMWCgA2FiEE
      xSeHPHtvanl+EKmVAlmlnDArxCQFAmYU2TECGwEECwkIBwQVCgkIBRYCAwEAAh4B
      AheAAAoJEAJZpZwwK8QkcdMA/iGTyT+3tQuPuB1SfIU+arO/YNLrQyrVNKFLzeN9
      Lxr1AQD5iOuGqM13vePf/V1pdTqSviYYFiID1uZVqdZkEpMjCLgzBGYU2TQWCSsG
      AQQB2kcPAQEHQNjA5piZI3P+dA4G5BMKxoKoEXpMhL5MgTuDqyBZHBjpiPUEGBYK
      ACYWIQTFJ4c8e29qeX4QqZUCWaWcMCvEJAUCZhTZNAIbAgUJA8JnAACBCRACWaWc
      MCvEJHYgBBkWCgAdFiEEIMba+HbLgp0Udn5bw5FmH1r+7UIFAmYU2TQACgkQw5Fm
      H1r+7UJQ4wEA/uPEY0oleGcppxvcKOJYYUteuExfqlB5Lyb7h2RALiYBALH2t4Ug
      GFpPnGPCBEtg8TYfe2c34UoAXKdYsOKL004MELMBAKCD9pzQK9KdTAQ8HiaTpzax
      fIbIsGdYDAey/MgCnqg7AP0eWGAd3U5HdL+yztO0GrHpvYOxJksSKOhGahogBLuS
      A7g4BGYU2TUSCisGAQQBl1UBBQEBB0Bpjp/YcUenNUFX7oBAyUEtWDHk+NhDGs7K
      ektqg1YvVwMBCAeIfgQYFgoAJhYhBMUnhzx7b2p5fhCplQJZpZwwK8QkBQJmFNk1
      AhsMBQkDwmcAAAoJEAJZpZwwK8QkvcUA/3+g729BCu+emFdtIAyIUyLFGbJYF8Ho
      uWeRpsCXadakAQC55vyXskTuA0GsVqw1FOYjJubtm7gbge5fF91CmWxjBbgzBGYU
      2TYWCSsGAQQB2kcPAQEHQBY4WkZia6FBTSI/KCunUwhtWdX8ERWwyl/CHfPVxDYu
      iH4EGBYKACYWIQTFJ4c8e29qeX4QqZUCWaWcMCvEJAUCZhTZNgIbIAUJA8JnAAAK
      CRACWaWcMCvEJKV7AP4wwIvseCOiOmI6BA6sjpTUmMIX9xoOTh2Yr1m3wxmRQQEA
      9yyj+QWM6N+taXwrxl+YZeHC3XRH5hezX0gcIVMhZQo=
      =kXUs
      -----END PGP PUBLIC KEY BLOCK-----

  - uid: mariadoc
    public_key: |-
      […]
```

## Running the playbook

Make sure you have the following line in your `ansible.cfg` configuration file:

```ini
filter_plugins = {{ playbook_dir }}/../../common/filter-plugins/
```

```sh
ROLE=openpgp-wkd ansible-playbook install.yml
```

The installation will do the following:

- Create the certificates for the web site.
- Configure the web site that will publish the keys.
- Publish the GPG public keys, both using the _advanced_ and the _direct_ method.
- Add additional configuration to AppArmor.

## Checking the keys publication status

```sh
ROLE=openpgp-wkd ansible-playbook check.yml
```

## Uninstalling

```sh
ROLE=openpgp-wkd ansible-playbook uninstall.yml
```
