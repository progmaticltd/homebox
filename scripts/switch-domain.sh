#!/bin/sh

# Switch from one configuration to another. Useful if you have multiple domains to work on.

domain=$1

if [ "$domain" = "" ]; then
    echo "Usage: $0 <domain>"
    echo "Use symbolic links to create configuration files for the domain specified."
    echo "Example:"
    echo "  '$0 perso.home' will link system-perso.home.yml to system.yml and hosts-perso.home.yml to hosts.yml"
    exit 1
fi

SCRIPT=$(realpath "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

if [ ! -d "$SCRIPT_PATH/../config" ]; then
    echo "The folder $SCRIPT_PATH/../config does not exists"
    exit 1
fi

cd "$SCRIPT_PATH/../config" || exit

if [ ! -f "system-${domain}.yml" ]; then
    echo "Create the system-${domain}.yml file in config first."
    echo "See system-example.yml for bare minimum and defaults.yml for all possible values"
    exit 2;
fi

if [ ! -f "hosts-${domain}.yml" ]; then
    echo "Create the hosts-${domain}.yml file in config folder first. See hosts-example.yml"
    exit 2
fi

ln -nsf "system-${domain}.yml" system.yml
ln -nsf "hosts-${domain}.yml" hosts.yml

# Display the output
ls -l system.yml
ls -l hosts.yml
