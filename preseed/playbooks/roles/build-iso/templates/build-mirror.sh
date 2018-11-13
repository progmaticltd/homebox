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

# Build the mirror repositories option
export MIRROR_OPTIONS="--do-mirror ${COMMON_OPTS} --mirror-only"

# Build the mirror
simple-cdd $MIRROR_OPTIONS
