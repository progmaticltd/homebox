
HomeBox
=======

A simple set of Ansible scripts to create a ready to use personal mail server for home...

What do you need?
-----------------

Basic requirements

- Some basic newtork knowledge
- A fixed IP address from your ISP
- A low consumption hardware box to plug on your router, with a basic Debian Jessie installed
- A computer to run the Ansible scripts
- A registered domain name

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
