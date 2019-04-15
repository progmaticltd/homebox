<?php

/**
 * Minimal plugin to forward the real IP address to the IMAP server
 *
 * @version 1.0
 * @author André Rodier
 * @description Pass the real IP address to Dovecot using the ID extension
 *
 * Shamelessly based on https://github.com/roundcube/roundcubemail/issues/5336
 *
 * Also see Dovecot parameters forwarding:
 * https://wiki.dovecot.org/Design/ParameterForwarding
 */

class dovecot_ident extends rcube_plugin
{
    function init()
    {
        $this->add_hook('storage_connect', [$this, 'add_ident']);
    }

    function add_ident($args)
    {
        $remoteIP = $_SERVER['REMOTE_ADDR'];
        $identInfo = [
            'x-originating-ip' => $remoteIP,
            'x-connected-ip' => '127.0.0.2'
        ];

        if ($args['ident']) {
            $args['ident'] = array_merge($args['ident'], $identInfo);
        } else {
            $args['ident'] = $identInfo;
        }

        return $args;
    }
}

?>
