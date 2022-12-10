#!/bin/dash

echo "Reloading LDAP server"

# Stop ldap dependant services
systemctl stop unscd
systemctl stop nslcd

# Restart LDAP
systemctl restart slapd

# Start ldap dependant services
systemctl start nslcd
systemctl start unscd
