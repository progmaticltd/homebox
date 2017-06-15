
HomeBox
=======

A simple set of Ansible scripts to create a ready to use personal mail server for home...

What do you need?
-----------------

Basic requirements

- A low consumption hardware box to plug on your router, with a basic Debian Jessie installed
- A computer to run the Ansible scripts
- A registered domain name, with [Gandi](https://gandi.net/)
- A fixed IP address from your ISP
- Some basic newtork knowledge

Current status:
---------------

The script is actually in its embryonic state, and set up the following:

- Install some required packages
- Create the user accounts
- Install Postfix mail transfer agent
- Install Dovecot mail server
- Install PostgreSQL for the database
- Install Nginx and Roundcube webmail for the frontend
- Use LetsEncrypt scripts to create certificates for subdomains
  - postfix: smtp.example.com
  - dovecot: imap.example.com
  - the webmail: webmail.example.com
- Configure the firewall on the box

About the DNS provider
----------------------

The script also automatically register the domains entires to the domain provider, if you provide an API key. This is useful so you do not have to manage the DNS entries yourself:
  
  1. Visit the [API key page on Gandi](https://www.gandi.net/admin/api_key)
  2. Activate of the API on the test platform (OT&E).
  3. Activate of the production API

Your API key is being activated on the test platform (OT&E). It will be available to you on this page shortly.
