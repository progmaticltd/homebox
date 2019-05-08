## Alternatives

There is already a lot of excellent projects on internet to help emails self-hosting, and I am providing links in the
[index page](index.md).

This one is different in the approach used, and I do not want to deviate.

It is made to be unobtrusive with a standard Debian distribution, stable and highly secure.

## Security

Security is the main concern of this solution. All the packages are coming from the __official Debian repository__ or
from a __well maintained repository__.  There is no *git clone* or manual download here, ever.  Once installed, you
should be able to manage it like any Debian server.

Any new service should be compatible with [AppArmor](https://en.wikipedia.org/wiki/AppArmor), to secure the system and
to protect from any zero-day vulnerability.

I am privileging stability and security over features, this is why you will not have the latest version of RoundCube and
other components.

## Standard compliance

It is also standard compliant. For instance, the system generates and _publish_ automatically your DKIM, SPF and DMARC
records.

Any service that requires authentication should use LDAP. so the user don't have to remember another password.

## Shell scripts

- When shell scripts are needed, [dash](https://en.wikipedia.org/wiki/Almquist_shell#dash) should be preferred over bash.
- Each shell should be checked with shellcheck binary.

## Current status

- Although the platform is actually stable enough to be used in production, it is not yet a turn-key solution for lambda
  users.
- Some functionalities - not activated by default - have not been tested in a live environment for long enough.
  
Some components are missing, and will be added when appropriate:

- A proper Debian repository for the security updates of the scripts, if this is needed.
- A proper roadmap, with major and minor version numbers.
- A mailing list, mostly for announces.
- An official web site

I have more long term ideas in mind, I will document them more in details later.
