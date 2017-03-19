
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


Current status:
---------------

The script is actually in its embryonic state, and set up the following:

- Install some basic required packages
- Create the accounts on the server
- Install Dovecot mail server
- Install PostgreSQL for the database
- Install Nginx and Roundcube webmail for the frontend
- Configure the firewall on the box
