<?php
// Zabbix GUI configuration file.
global $DB;

$DB['TYPE']     = 'POSTGRESQL';
$DB['SERVER']   = 'localhost';
$DB['PORT']     = '5432';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = '{{ zabbixdb_password }}';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = 'localhost';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'local';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
