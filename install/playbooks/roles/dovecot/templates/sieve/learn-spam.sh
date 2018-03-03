#!/bin/bash

exec /usr/bin/rspamc -h localhost:{{ rspamd.controller.port }} learn_spam

