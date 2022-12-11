## Alternatives

There is already a lot of excellent projects on the internet to help emails self-hosting, and I am providing links in
the [index page](index.md).

This one is different in the approach used, and I do not want to deviate.

It is made to be unobtrusive with a standard Debian distribution, stable and highly secure.

## Security

Security is the main concern of this solution. All the packages are coming from the __official Debian repository__ or
from a __well maintained repository__.  There is no *git clone* or manual download here, ever.  Once installed, you
should be able to manage it like any Debian server.

Any new service should be compatible with [AppArmor](https://en.wikipedia.org/wiki/AppArmor), to secure the system and
to protect it from any zero-day vulnerability.

I am privileging stability and security over features, this is why you will not have the latest version of any
component.

The firewall is installed from the start, with inbound, outbound and forwarding rules.

External web access is blocked by default, using a whitelist proxy. Only a few sites, like debian servers, are
accessible, even for root.

## Standard compliance

It is also standard compliant. For instance, the system generates and _publish_ automatically your DKIM, SPF and DMARC
records. DKIM certificates are automatically renewed every year.

Any service that requires authentication should use LDAP, so the user doesn't have to remember another password.

## Current status

- Although the platform is actually stable enough to be used in production, it is not a turn-key solution for lambda
  users, and will never be.

I have more long term ideas in mind, I will document them more in details later.

## Shell scripts

- When shell scripts are needed, [dash](https://en.wikipedia.org/wiki/Almquist_shell#dash) should be preferred over bash.
- Each shell should be checked with the shellcheck binary.
