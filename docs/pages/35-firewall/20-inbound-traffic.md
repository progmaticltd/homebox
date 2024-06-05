# Inbound traffic

Once the minimal set of rules is deployed, any other role installation can add specific rules
files in the `/etc/nftables` folder. For instance, when installing the Jabber server,
additional rules are deployed for client to server and server to server connectivity (ports
5222 and ports 5223).

Conversely, when the Jabber de-installation tasks are executed, the same rules are removed,
and the firewall is reloaded.
