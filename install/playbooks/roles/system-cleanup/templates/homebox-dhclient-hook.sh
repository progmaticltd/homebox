#!/bin/sh

cat << end > /etc/resolv.conf
# Use the internal bind server
nameserver 127.0.0.1
end
