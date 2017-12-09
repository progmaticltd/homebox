
HomeBox
=======

A simple set of Ansible scripts to create a ready to use personal mail server for home...

What do you need?
-----------------

Basic requirements

- A low consumption hardware box to plug on your router, with a basic Debian Stretch installed
- A computer to run the Ansible scripts
- A fixed IP address from your ISP
- Some basic newtork knowledge

In the future:
- A registered domain name, with [Gandi](https://gandi.net/)

Current status:
---------------

The script is actually doing following:

- Install some required packages.
- Install a simple LDAP server (openLDAP).
- Create an SSL certificate for the LDAP server.
- Create the user accounts in the directory, and integrate it into the system using pam_ldap and nslcd.
- Install Postfix mail transfer agent, with a dedicted SSL certificate.
- Install Dovecot mail server, with a dedicted SSL certificate.
- Install PostgreSQL for the database.
- Install Nginx and Roundcube webmail for the frontend.
- Configure the firewall on the box

The certificates are generated using LetsEncrypt service, with one for each service. Examples for example.com domain:
  - openldap: ldap.example.com
  - postfix: smtp.example.com
  - dovecot: imap.example.com
  - the webmail: webmail.example.com

Automatic update of the DNS entries
-----------------------------------

In the future, a custom script will automatically register domains entries to Gandi, if you provide an API key. This is useful so you do not have to manage the entries yourself, or if you don't have a fixed IP address.

Here what to do to get the API key:

  1. Visit the [API key page on Gandi](https://www.gandi.net/admin/api_key)
  2. Activate of the API on the test platform.
  3. Activate of the production API

Your API key will be activated on the test platform.
