#!/bin/dash

# Get the domain
domain=$(hostname -d)

# Check what time the service has been restarted
svc_time=$(systemctl show ejabberd --value --property=ActiveEnterTimestamp --timestamp=unix | sed s/@//)

# Compare the timestamp of each certificate
certs="conference files upload vjud pubsub proxy xmpp"

for cert in $certs; do
    cert_time=$(stat -c %Y "/var/lib/lego/certificates/$cert.$domain.crt")

    # Check if the service start time is after
    # the last modification time of the certificate
    printf "$cert.$domain: "
    if [ $svc_time -gt $cert_time ]; then
        echo "OK"
        continue
    fi

    echo "renewed."
    echo " - restarting ejabberd service."
    systemctl restart ejabberd
    break

done
