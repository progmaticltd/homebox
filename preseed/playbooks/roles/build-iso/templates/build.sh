#!/bin/bash

# The first parameter is the name of the server to build the iso image
HOSTNAME=$1

# Use proxy if defined
export http_proxy='{{ network.main.proxy }}'

# Parameters
DIST='{{ repo.release }}'
LOCALE='{{ locale.id }}'

# Extra profiles to include
PROFILES='{{ cdimage.profiles }}'

# Mirror (TODO: Check httpredir ?)
MIRROR='http://{{ repo.main }}/debian/'

# Common options
COMMON_OPTS="--force-root --debian-mirror ${MIRROR} --locale ${LOCALE} --dist ${DIST}"

# Build the mirror repositories
OPTIONS="--do-mirror ${COMMON_OPTS}"
simple-cdd $OPTIONS

# Create the miscellaneous files archive
tar c --remove-files -C /tmp/homebox/misc -z -f /tmp/homebox/misc.tgz .

# Build installer CDs for the whole platform
OPTIONS="--verbose"
OPTIONS+=" --build-only ${COMMON_OPTS}"
OPTIONS+=" --dvd --conf common.conf"

# Add extra profiles if defined
if [ "$PROFILES" ne "" ]; then
    OPTIONS+="--profiles $PROFILES "
fi

# Set keyboard configuration
OPTIONS+=" --keyboard {{ locale.keymap }}"

# Where to save the logs:
LOGFILE="/tmp/homebox/logs/${HOSTNAME}-cdd.log"
test -d /tmp/homebox/logs || mkdir /tmp/homebox/logs

OPTIONS+=" --logfile ${LOGFILE}"

# Run the program to build the images
simple-cdd $OPTIONS

