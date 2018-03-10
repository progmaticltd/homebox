#!/bin/dash

exec /usr/bin/rspamc -h localhost:{{ milter_antispam_port }} learn_spam

