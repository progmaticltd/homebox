# Fake homebox docker instance
FROM debian:stable

# Needed to download backports
RUN apt-get update && apt-get install -y ca-certificates

RUN echo "deb https://deb.debian.org/debian/ buster-backports main contrib non-free" >>/etc/apt/sources.list
RUN apt-get update

# Base packages
RUN apt-get install -y python ca-certificates

RUN apt-get update && apt-get install -y openssh-server

# Fake systemctl command for Ansible handlers
RUN apt-get install -y systemctl

# Create SSH directory
RUN mkdir /root/.ssh
COPY id_rsa.pub /root/.ssh/authorized_keys

# Start the SSH server on port 2222
## Fix ownership on the ssh folder and files
EXPOSE 2222
RUN mkdir /run/sshd
CMD [ "/usr/sbin/sshd", "-D", "-4", "-p", "2222" ]
