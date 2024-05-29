#!/usr/bin/dash
#
## Switch from one configuration to another. Useful if you have multiple domains to work on.
## Usage: $0 <domain>
## Use symbolic links to create configuration files for the domain specified.
##
## Example:
##   switch-domain.sh perso.home
##
## Will create the following symbolic links:
##   system-perso.home.yml → system.yml
##   hosts-perso.home.yml → hosts.yml
##
## Then will validate the syntax of the YAML files with yamllint if present
#

usage() {
    sed -En 's/^## ?//p' "$0"
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 1
fi

# Read the domain
domain=$1

if [ "$domain" = "" ]; then
    usage
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
    echo "See system-minimal.yml for bare minimum and defaults.yml for all possible values"
    exit 2;
fi

if [ ! -f "hosts-${domain}.yml" ]; then
    echo "Create the hosts-${domain}.yml file in config folder first. See hosts-example.yml"
    exit 2
fi

# Check if the files are valid before creating the symbolic links
if yamllint --version >/dev/null 2>&1; then

    echo "Checking the syntax of YAML files first:"

    printf "  Checking the syntax of  %s: " "system-${domain}.yml"

    if ! yamllint -c ../config/yaml-lint.yml "system-${domain}.yml"; then
        echo "Fail"
        echo "Warning, the file 'system-${domain}.yml' contains errors."
    else
        echo "OK"
    fi

    printf "  Checking the syntax of  %s: " "hosts-${domain}.yml"

    if ! yamllint -c ../config/yaml-lint.yml "hosts-${domain}.yml"; then
        echo "Fail"
        echo "Warning, the file 'hosts-${domain}.yml' contains errors."
    else
        echo "OK"
    fi

fi

echo "\nSwitching to the domain $domain:"

ln -nsf "system-${domain}.yml" system.yml
ln -nsf "hosts-${domain}.yml" hosts.yml

# Show IP addresses
external_ip=$(sed -En 's/  external_ip: ([0-9a-f\.:-]+).*/\1/p' system.yml)
backup_ip=$(sed -En 's/  backup_ip: ([0-9a-f\.:-]+).*/\1/p' system.yml)

if [ -n "$external_ip" ]; then
    printf "  External IP address: %s" "$external_ip"

    if getent hosts "$external_ip" >/dev/null 2>&1; then
        echo "Valid"
    else
        echo " (Check this please !)"
    fi
fi

if [ -n "$backup_ip" ]; then
    printf "  Backup IP address: %s" "$backup_ip"

    if getent hosts "$backup_ip" >/dev/null 2>&1; then
        echo "Valid"
    else
        echo " (Check this please !)"
    fi
fi
