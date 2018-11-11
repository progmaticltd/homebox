# Start from Debian stable (Stretch)
FROM debian:stable

# Add backports repository
RUN echo 'deb http://deb.debian.org/debian/ stretch-backports main contrib non-free' >>/etc/apt/sources.list

# Install the required package
RUN apt -qq update

# Create a dedicated user for simplecdd
RUN useradd -ms /bin/dash cdbuild

# Copy the SSH key into the misc directory, that will be put on the CD image
RUN mkdir -p /home/cdbuild/misc/root/.ssh
COPY --chown=cdbuild:cdbuild ./config/authorized_keys /home/cdbuild/misc/root/.ssh/authorized_keys

# Install the last version of simple-cdd
RUN apt -qq install -t stretch-backports -y simple-cdd

# Install the last version of ansible to build the preseed file
RUN apt -qq install -t stretch-backports -y ansible

# Copy the miscellaneous files to be part of the CD image
# but remove the doc file
COPY --chown=cdbuild:cdbuild ./misc /home/cdbuild/misc/
RUN rm -f /home/cdbuild/misc/readme.md

# Copy the playbooks and the configuration
COPY --chown=cdbuild:cdbuild ./playbooks /home/cdbuild/playbooks/
COPY --chown=cdbuild:cdbuild ./config /home/cdbuild/config/

# Build the ISO image
USER cdbuild
WORKDIR /home/cdbuild

# Copy the Ansible configuration file
COPY --chown=cdbuild:cdbuild ansible/ansible.cfg /home/cdbuild

# Create a simple host file for localhost to avoid Ansible warning
COPY --chown=cdbuild:cdbuild ansible/hosts.yml /home/cdbuild

# Run the ansible playbook
RUN ansible-playbook -vv -i hosts.yml -l localhost playbooks/docker.yml

# Build the mirror using simple-cdd
RUN cd /tmp/build-homebox && ./build-mirror.sh

# And build the CD image
RUN cd /tmp/build-homebox && ./build-cd.sh

# Copy the final ISO image into the host shared folder
ENTRYPOINT cp /tmp/build-homebox/images/*.iso /tmp/homebox-images/

# For debugging
ENTRYPOINT /bin/bash
