# Outbound traffic

The outbound traffic is filtered as well, using a while list model, i.e. any connection not explicitly authorised is
rejected.

Authorised connections:

- DNS queries to a set of pre-defined DNS servers only.
- NTP queries to a set of pre-defined NTP servers only.
- Whois queries from the root user only.
- Web traffic to some sites, specifically the Debian repositories and LetsEncrypt servers.

whitelisted_hosts:

- api.ipify.org
- api64.ipify.org
- deb.debian.org
- letsencrypt.org
- security.debian.org

## Filtering proxy

The web traffic is restricted by tinyproxy whitelisting, with only the Debian repository servers being authorised.
