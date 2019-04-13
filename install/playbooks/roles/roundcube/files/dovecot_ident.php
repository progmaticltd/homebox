<?php

/**
 * Plugin to add imap ID
 *
 * @version 1.0
 * @author André Rodier
 * @description Pass the real IP address to Dovecot using the ID extension
 *
 * Shamelessly based on https://github.com/roundcube/roundcubemail/issues/5336
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
        $identInfo = [ 'x-originating-ip' => $remoteIP ];

        if ($args['ident']) {
            $args['ident'] = array_merge($args['ident'], $identInfo);
        } else {
            $args['ident'] = $identInfo;
        }

        return $args;
    }
}

?>
