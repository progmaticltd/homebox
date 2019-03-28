# Tor and Privoxy

The _Onion Router_ Tor, can be installed, along with _Privoxy_, in a very simplistic configuration.
Privoxy is a free non-caching web proxy with filtering capabilities for enhancing privacy.

It provides a basic privacy protection, alongside wih some browsers extensions. More information on
this page: [https://restoreprivacy.com/firefox-privacy/](https://restoreprivacy.com/firefox-privacy/).

You may also want to select an alternative search engine like [DuckDuckGo](https://duckduckgo.com/).

### Privoxy adblock lists synchronisation

The privoxy server can be synchronised daily with easylists networks, to protect both your privacy
and your network bandwidth.

The default rules are:

#### EasyList

EasyList is the primary filter list that removes most adverts from international webpages, including
unwanted frames, images and objects. It is the most popular list used by many ad blockers and forms
the basis of over a dozen combination and supplementary filter lists.

#### EasyPrivacy

EasyPrivacy is an optional supplementary filter list that completely removes all forms of tracking
from the internet, including web bugs, tracking scripts and information collectors, thereby
protecting your personal data.

#### Fanboy's Annoyance List

Fanboy's Annoyance List blocks Social Media content, in-page pop-ups and other annoyances; thereby
substantially decreasing web page loading times and uncluttering them. Fanboy's Social Blocking List
is already included, there is no need to subscribe to it if you already have Fanboy's Annoyance
List.

#### Fanboy's Social Blocking List

Fanboy's Social Blocking List solely removes Social Media content on web pages such as the Facebook
like button and other widgets.

#### Other Supplementary Filter Lists and EasyList Variants

Other lists can be downloaded on the [Supplementary Filter Lists and Variants
page](https://easylist.to/pages/other-supplementary-filter-lists-and-easylist-variants.html).

## Default configuration

The configuration actually installed is the default one on Debian, but you can easily customise it
using the standard Tor or Privoxy options.

Tor is not accessible externally.
Privoxy is listening on port 8118, on the LAN by default.

Both are configured to run in AppArmor profile.

### Minimal configuration

```yaml

# Secure / Anonymous proxy
tor:
  install: true

privoxy:
  install: true

```

### Chaining privoxy and Tor

It is possible to chain privoxy and tor, to use both proxies at the same time. If you have activated
the easyprivacy list of privoxy, this will give you a good anonymous and privacy filter, even for
devices that don't support Tor or SOCKS proxy natively.

For instance:

```yaml

# Privoxy privacy proxy
privoxy:
  install: true
  tor_forward: false
  adblock_rules:
    install: true
    list:
      - https://easylist.to/easylist/easylist.txt
      - https://easylist.to/easylist/easyprivacy.txt
      - https://easylist.to/easylist/fanboy-annoyance.txt
      - https://easylist.to/easylist/fanboy-social.txt
      - https://easylist-downloads.adblockplus.org/liste_fr.txt
  port: 8118
  accept_from:
    - 192.168.64.0/24
    - 192.168.65.0/24
    - 192.168.66.0/24
    - 172.16.0.0/16
    - 172.16.65.0/24
  custom_settings: |
    # Put anything you want here,
    # even on multiple lines

```

### Default configuration

```yaml

# The onion router
tor:
  install: false
  port: 9050
  accept_from:
    - 127.0.0.1

# Privoxy privacy proxy
privoxy:
  install: false
  tor_forward: false
  port: 8118
  accept_from:
    - 10.0.0.0/8
    - 192.168.0.0/16
    - 172.16.0.0/20
  adblock_rules:
    install: true
    list:
      - https://easylist.to/easylist/easylist.txt
      - https://easylist.to/easylist/easyprivacy.txt
      - https://easylist.to/easylist/fanboy-annoyance.txt
      - https://easylist.to/easylist/fanboy-social.txt
  custom_settings: |
    # Put anything you want here,
    # even on multiple lines
```

