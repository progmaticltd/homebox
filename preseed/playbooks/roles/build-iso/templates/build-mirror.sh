#!/bin/bash

# The first parameter is the name of the server to build the iso image
export HOSTNAME={{ system.hostname }}

{% if debug %}
set -x
{% endif %}

# Use proxy if defined
{% if network.proxy is defined and network.proxy != False %}
export http_proxy='{{ network.proxy }}'
{% endif %}

# Parameters
DIST='{{ repo.release }}'
LOCALE='{{ locale.id }}'

# Build the default mirror URL
MIRROR='http://{{ repo.main }}/debian/'

# Common options
COMMON_OPTS="--debian-mirror ${MIRROR} --locale ${LOCALE} --dist ${DIST} --debug"

# Removed expired keys (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=928703)
cp /usr/share/keyrings/debian-archive-keyring.gpg ~/
apt-key --keyring ~/debian-archive-keyring.gpg del ED6D65271AACF0FF15D123036FB2A1C265FFB764

# Build the mirror repositories option
MIRROR_OPTIONS="--do-mirror ${COMMON_OPTS} --mirror-only --keyring ~/debian-archive-keyring.gpg"

# Build the mirror
simple-cdd $MIRROR_OPTIONS
