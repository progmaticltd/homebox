# Start from Debian stable (Stretch)
FROM debian:stable

# Add backports repository
RUN echo 'deb http://deb.debian.org/debian/ stretch-backports main contrib non-free' >>/etc/apt/sources.list

# Install the required package
RUN apt -q update

# Install the last version of Ansible
RUN apt -q install -t stretch-backports -y simple-cdd ansible

# Create a dedicated user for simplecdd
RUN useradd -ms /bin/dash cdbuild

# Copy the playbooks and the configuration
COPY --chown=cdbuild:cdbuild ./playbooks /home/cdbuild/playbooks/
COPY --chown=cdbuild:cdbuild ./config /home/cdbuild/config/
COPY --chown=cdbuild:cdbuild ./misc /home/cdbuild/misc/

# Remove the doc file
RUN rm -f /home/cdbuild/misc/readme.md

# Copy the SSH key into the misc directory, that will be put on the CD image
RUN mkdir -p /home/cdbuild/misc/root/.ssh
COPY --chown=cdbuild:cdbuild ./config/authorized_keys /home/cdbuild/misc/root/.ssh/authorized_keys

# Build the iSO image
USER cdbuild
WORKDIR /home/cdbuild

# Copy the Ansible configuration file
COPY --chown=cdbuild:cdbuild ansible.cfg /home/cdbuild

# Run the ansible playbook
ENTRYPOINT ansible-playbook -vv -l localhost playbooks/docker.yml

# For debugging
# ENTRYPOINT /bin/bash
