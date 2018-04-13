# Code of conduct

There is a lot of excellent projects on internet to help emails self-hosting, and I am providing links below. This one is different in the approach used.

It is made to be unobtrusive with a standard Debian distribution, stable and highly secure.

Security is a very important concern when using self hosting. All the packages are coming from the official Debian repository or from a well maintained repository. There is no *git clone* or manual download here. Moreover, the system also deploys and carefully configure [AppArmor](https://en.wikipedia.org/wiki/AppArmor), to secure the system and to protect you from any zero-day vulnerability.

There is no custom scripts to upgrade the system, it is set to use the standard Debian repositories, or at least official repositories when there is no Debian package. Once installed, manage it the way you like!

It is also standard compliant, as the system generates and _publish_ automatically your DKIM, SPF and DMARC records. It is actually using the excellent [Gandi](https://gandi.net) DNS provider, but can be extended to support more.

The authentication is done using an LDAP server. This allows to add more software and simgle sign on. I am planning to add more applications in the future.

Most of the tasks are automated, even the external IP address detection and DNS update process. In theory, you could use this with a dynamic IP address.

I am privileging stability and security over features, this is why you will not have the latest version of RoundCube and other components. There are plenty projects on internet that provides the latest and shinest versions of these software if you need. I am providing links at the end of this page.


