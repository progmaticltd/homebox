There is already a lot of excellent projects on internet to help emails
self-hosting, and I am providing links in the [index page](index.md).

This one is different in the approach used, and I do not want to deviate.

It is made to be unobtrusive with a standard Debian distribution,
stable and highly secure.

Security is a very important concern when using self hosting. All the
packages are coming from the official Debian repository or from a well
maintained repository. There is no *git clone* or manual download
here.

Any new service should be compatible with [AppArmor](https://en.wikipedia.org/wiki/AppArmor),
to secure the system and to protect from any zero-day vulnerability.

There is no custom scripts to upgrade the system, it is set to use the
standard Debian repositories, or at least official repositories when
there is no Debian package.
Once installed, you should be able to manage it like any Debian server.
No incompatible service installed

It is also standard compliant, as the system generates and _publish_
automatically your DKIM, SPF and DMARC records. It is actually using
the excellent [Gandi](https://gandi.net) DNS provider, but can be
extended to support more.

Any system should support LDAP for authentication, for single sign on.

I am privileging stability and security over features, this is why you
will not have the latest version of RoundCube and other components.
