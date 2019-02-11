#!/bin/dash

set -e

echo "Calling renewal hook: Start"

for fqdn in $RENEWED_DOMAINS; do

    sub=$(echo $fqdn | sed -r 's/\.?{{ network.domain }}//')
    echo "Domain $fqdn renewed (sub=$sub)"

    case $sub in

        # Calendar server (davical)
        caldav|carddav)
	    echo "Reloading calendar server"
	    systemctl status davical >/dev/null 2>&1 || continue
            systemctl restart davical
            systemctl restart nginx
            ;;

        # Restart the LDAP server
        ldap)
	    echo "Reloading LDAP server"
            systemctl restart slapd
            ;;

        # Restart the MTA server
        smtp)
	    echo "Reloading Postfix MTA"
            systemctl restart postfix
            ;;

        # Restart the MDA server
        imap|pop3)
	    echo "Reloading Dovecot MDA"
            systemctl restart dovecot
            ;;

        # Default nginx site
        www|$fqdn)
	    echo "Reloading main web site"
            systemctl restart nginx
            ;;

        # Transmission P2P web interface
        transmission)
	    echo "Reloading main web site"
            systemctl reload transmission-daemon
            systemctl restart nginx
            ;;

        # Auto-discovery for Outlook
        autodiscover)
	    echo "Reloading main web site"
            systemctl restart nginx
            ;;

        # Gogs site
        gogs)
	    echo "Reloading gogs web site"
            systemctl restart gogs
            systemctl restart nginx
            ;;

        # Webmail site
        webmail)
	    echo "Reloading webmail site"
            systemctl restart nginx
            ;;

        # rspamd site
        rspamd)
	    # Exit if rspamd server is not running
	    systemctl status rspamd >/dev/null 2>&1 || continue
	    echo "Reloading rspamd web interface"
            systemctl restart rspamd
            ;;

        # Jabber server
        xmpp|conference)
	    # Exit if jabber server is not running
	    systemctl status ejabberd >/dev/null 2>&1 || continue
	    echo "Reloading XMPP ejabberd server"
	    cd '/etc/letsencrypt/live/{{ network.domain }}'
	    /bin/cat privkey.pem fullchain.pem > /etc/ejabberd/default.pem
	    chown ejabberd:root /etc/ejabberd/default.pem
	    chmod 640 /etc/ejabberd/default.pem
            systemctl restart ejabberd
            systemctl restart nginx
            ;;

    esac
done

echo "Calling renewal hook: End"
