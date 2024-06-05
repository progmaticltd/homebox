# Outbound traffic

The outbound traffic is filtered as well, using a while list model, i.e. any connection
not explicitly authorised is rejected, based on the domain.

The authorised connections are:

- DNS queries DNS servers only.
- NTP queries NTP servers only.
- Whois queries from the root user only.
- Web traffic to some sites, specifically the Debian repositories and LetsEncrypt servers.

## Whitelisted domains

The web traffic is restricted by tinyproxy whitelisting, with only the Debian repository
servers being authorised.

- deb.debian.org
- security.debian.org
- letsencrypt.org

## Firewall role

Finally, when the firewall role creates two _redirect rules_, to intercept outbound
traffic going on ports 80 and 443, redirecting to the _tinyproxy_, configured in transparent
mode.
