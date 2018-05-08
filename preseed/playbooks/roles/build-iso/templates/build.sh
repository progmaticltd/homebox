#!/bin/bash

# The first parameter is the name of the server to build the iso image
HOSTNAME=$1

{% if debug %}
set -x
{% endif %}

# Remove the previous version
rm -f '{{ build_dir }}/images/debian-{{ system.version }}-{{ system.arch }}-DVD-1.iso'

# Use proxy if defined
{% if network.proxy is defined %}
export http_proxy='{{ network.proxy }}'
{% endif %}

# Parameters
DIST='{{ repo.release }}'
LOCALE='{{ locale.id }}'

# Mirror (TODO: Check httpredir ?)
MIRROR='http://{{ repo.main }}/debian/'

# Common options
COMMON_OPTS="--debian-mirror ${MIRROR} --locale ${LOCALE} --dist ${DIST} --debug"

# Build the mirror repositories
OPTIONS="--do-mirror ${COMMON_OPTS}"
simple-cdd $OPTIONS

# Create the miscellaneous files archive, as root.
tar c -C "{{ playbook_dir }}/../misc" \
    --group=root --owner=root \
    -z -f "{{ build_dir }}/misc.tgz" .

# Build installer CDs for the whole platform
OPTIONS="--verbose"
OPTIONS+=" --build-only ${COMMON_OPTS}"
OPTIONS+=" --dvd --conf common.conf"

# Set keyboard configuration
OPTIONS+=" --keyboard {{ locale.keymap }}"

# Where to save the logs:
LOGFILE="{{ build_dir }}/logs/${HOSTNAME}-cdd.log"
test -d "{{ build_dir }}/logs" || mkdir "{{ build_dir }}/logs"

OPTIONS+=" --logfile ${LOGFILE}"

# Run the program to build the images
simple-cdd $OPTIONS
