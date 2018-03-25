#!/bin/bash

# This is a simple script that buid the CD image
# inside a docker container running simple-cdd on Debian stretch
#

# The most important is the configuration file 'system.yml'

# Build the docker image
docker-compose build cdbuild

# Run the docker container.
# Simple cdd is called using Ansible scripts
docker run -v /tmp:/tmp cdbuild:latest

# The iso image is in /tmp/${hostname}-install.iso
