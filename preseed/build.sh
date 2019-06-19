#!/bin/dash

# This is a simple script that buid the CD image
# inside a docker container running simple-cdd on Debian stretch
# The most important is the configuration file 'system.yml' in the preseed folder

# Build the docker image
docker-compose build cdbuild

# Create the temporary folder that will contains the ISO image for the installer
test -d /tmp/homebox-images || mkdir /tmp/homebox-images

# The Docker account (uid=1000, gid=1000)
chmod 775 /tmp/homebox-images
chgrp 1000 /tmp/homebox-images

# Run the docker container, that will do the following:
# 1 - Install the latest version of Ansible
# 2 - Run the Ansible playbook to create simple-cdd configuration
# 3 - Run simple-cdd to create custom iso image installer
docker run \
       --mount type=bind,source=/tmp/homebox-images,target=/tmp/homebox-images \
       cdbuild:latest bash -c 'cp /tmp/build-homebox/images/*.iso /tmp/homebox-images'
