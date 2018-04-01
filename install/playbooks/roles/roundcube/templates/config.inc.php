<?php

/*
+-----------------------------------------------------------------------+
| Local configuration for the Roundcube Webmail installation.           |
|                                                                       |
| This is a sample configuration file only containing the minimum       |
| setup required for a functional installation. Copy more options       |
| from defaults.inc.php to this file to override the defaults.          |
|                                                                       |
| This file is part of the Roundcube Webmail client                     |
| Copyright (C) 2005-2013, The Roundcube Dev Team                       |
|                                                                       |
| Licensed under the GNU General Public License version 3 or            |
| any later version with exceptions for skins & plugins.                |
| See the README file for a full license statement.                     |
+-----------------------------------------------------------------------+
*/

$config = array();

/* Do not set db_dsnw here, use dpkg-reconfigure roundcube-core to configure database ! */
include_once("/etc/roundcube/debian-db-roundcube.php");

// The mail host chosen to perform the log-in.
// Leave blank to show a textbox at login, give a list of hosts
// to display a pulldown menu or set one host as string.
// To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://
// Supported replacement variables:
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %s - domain name after the '@' from e-mail address provided at login screen
// For example %n = mail.domain.tld, %t = domain.tld
{% if system.ssl != False %}
$config['default_host'] = 'tls://imap.{{ network.domain }}:1143/';
{% else %}
$config['default_host'] = 'imap://imap.{{ network.domain }}/';
{% endif %}
// SMTP server host (for sending mails).
// To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://
// If left blank, the PHP mail() function is used
// Supported replacement variables:
// %h - user's IMAP hostname
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %z - IMAP domain (IMAP hostname without the first part)
// For example %n = mail.domain.tld, %t = domain.tld
{% if system.ssl != False %}
$config['smtp_server'] = 'tls://smtp.{{ network.domain }}';
{% else %}
$config['smtp_server'] = 'smtp.{{ network.domain }}';
{% endif %}

// SMTP port (default is 25; use 587 for STARTTLS or 465 for the
// deprecated SSL over SMTP (aka SMTPS))
$config['smtp_port'] = 25;

// SMTP username (if required) if you use %u as the username Roundcube
// will use the current username for login
$config['smtp_user'] = '%u';

// SMTP password (if required) if you use %p as the password Roundcube
// will use the current user's password for login
$config['smtp_pass'] = '%p';

// provide an URL where a user can get support for this Roundcube installation
// PLEASE DO NOT LINK TO THE ROUNDCUBE.NET WEBSITE HERE!
$config['support_url'] = '';

// Name your service. This is displayed on the login screen and in the window title
$config['product_name'] = '{{ roundcube.title }}';

// this key is used to encrypt the users imap password which is stored
// in the session record (and the client cookie if remember password is enabled).
// please provide a string of exactly 24 chars.
// YOUR KEY MUST BE DIFFERENT THAN THE SAMPLE VALUE FOR SECURITY REASONS
$config['des_key'] = '{{ makepasswd.stdout }}';

// List of active plugins (in plugins/ directory)
// Debian: install roundcube-plugins first to have any
$config['plugins'] = {{ plugins }};

{% if mail.impersonate.active %}
# Add the dovecot impersonate plugin
$config['plugins'][] = 'dovecot_impersonate';
{% endif %}

// skin name: folder from skins/
$config['skin'] = 'larry';

// Disable spellchecking
// Debian: spellshecking needs additional packages to be installed, or calling external APIs
//         see defaults.inc.php for additional informations
$config['enable_spellcheck'] = false;

# Auto-complete address books
$rcmail_config['autocomplete_addressbooks'] = ['sql', 'users'];

$config['ldap_public']['users'] = [
    'name'             => 'Users',
    'hosts'            => [ 'ldap.{{ network.domain }}' ],
    'port'             => 389,
    'user_specific'    => false,
    'writeable'        => false,
    'scope'            => 'sub',
    'base_dn'          => '{{ ldap.organization.base }}',
    'bind_dn'          => 'cn=readonly account,{{ ldap.users.dn }}',
    'bind_pass'        => '{{ lookup("password", roPasswdParams) }}',
    'name_field'       => 'cn',
    'email_field'      => 'mail',
    'surname_field'    => 'sn',
    'firstname_field'  => 'givenName',
    'sort'             => 'sn',
    'filter'           => '(|(mail=*)(intlMailAddr=*))',
    'search_fields'    => ['mail', 'cn', 'givenName', 'sn', 'intlMailAddr'],
    'global_search'    => true,
    'fuzzy_search'     => true,
    'groups'           => [
        'base_dn'         => '{{ ldap.groups.dn }}',
        'filter'          => '(objectClass=postixGroup)',
        'object_classes'  => [ 'top', 'postixGroup' ]
    ]
];

// Disables saving sent messages in Sent folder (like gmail)
// The SMTP server does that already
$config['no_save_sent_messages'] = true;

// Allow browser-autocompletion on login form.
$config['login_autocomplete'] = 2;

// Message size limit. Note that SMTP server(s) may use a different value.
// This limit is verified when user attaches files to a composed message.
// Size in bytes (possible unit suffix: K, M, G)
$config['max_message_size'] = '{{ mail.max_attachment_size }}M';

// Lock identities as they are coming from the LDAP server
// Set identities access level:
// 0 - many identities with possibility to edit all params
// 1 - many identities with possibility to edit all params but not email address
// 2 - one identity with possibility to edit all params
// 3 - one identity with possibility to edit all params but not email address
// 4 - one identity with possibility to edit only signature
$config['identities_level'] = 0;