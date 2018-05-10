#!/bin/dash

exec /usr/bin/rspamc -h localhost:{{ mail.antispam.port }} learn_ham
