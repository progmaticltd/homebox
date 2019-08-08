#!/usr/bin/env python2

# Search inside a shared database to check if the message is coming
# from a known email address stored in a user's address book.
# I use http://bmsi.com/python/milter.html
# This is actually compatible with Python2 / Debian Stretch.
# Since the package python3-milter is included in Debian Buster,
# a new version will be written for Python 3.

# Andre Rodier <andre@rodier.me>
# Licence: GPL v2

# Pylint options
# too long lines: pylint: disable=C0301
# catching too general exception: pylint: disable=W0703
# too many instance attributes: pylint: disable=R0902
# parameters differ from overriden: pylint: disable=W0221

# To test with sqlite, use:
# sqlite3 -batch /var/lib/milter-abook/addresses.db
# 'create table if not exists addresses (
# uid        VARCHAR,
# source     VARCHAR,
# abook      VARCHAR,
# email_hash VARCHAR
# )';
# sqlite3 -batch /var/lib/milter-abook/addresses.db
# 'CREATE INDEX email_idx ON addresses (uid, email_hash)';

# Make sure pylint knows about the print function
from __future__ import print_function

import Milter
from Milter.utils import parse_addr

import StringIO
import sys
import os
import psycopg2
import ConfigParser
from socket import AF_INET6

# For logging queue
from multiprocessing import Process as Thread, Queue

# Constants related to the systemd service
SOCKET_PATH = "/run/milter-abook/milter-abook.socket"
PID_FILE_PATH = "/run/milter-abook/main.pid"

GlobalLogQueue = Queue(maxsize=100) # type: Queue[str]

configParser = ConfigParser.RawConfigParser()
configFilePath = '/etc/sogo/milters.conf'
configParser.read(configFilePath)

# This implementation use a simple sqlite database, mainly for testing.
# The records in the database are anonymised using sha256, for security purposes
def searchInSQLite(fromAddress, recipients, debug):
    """Search for an address in a local sqlite database. Only email hashes are stored (sha256)"""
    sources = []

    try:

        import sqlite3
        import hashlib

        query = 'select source,abook from addresses where uid="{0}" and email_hash="{1}"'
        sqliteDatabase = configParser.get('sqlite', 'path')
        db = sqlite3.connect(sqliteDatabase)

        # Check if the email address is in the user's address book
        cursor = db.cursor()

        # get the from email address signature
        emailHash = hashlib.sha256(fromAddress).hexdigest()

        for rec in recipients:
            parts = parse_addr(rec[0])
            uid = parts[0]
            cursor.execute(query.format(uid, emailHash))

            # Store the address book sources when found
            for row in cursor:
                sources.append('{0}:{1}'.format(row[0], row[1]))

        if debug:
            GlobalLogQueue.put("Searched address hash {} for user {}: {} result(s)".format(
                emailHash, uid, len(sources)))

    # Make sure to not prevent the message to pass if something happen,
    # but log the error
    except Exception as error:
        GlobalLogQueue.put("Error when searching in address database: {}".format(error.message))

    # Cleanup: close the db connection if needed
    finally:
        if db:
            db.close()

    return sources


def searchInSOGo(fromAddress, recipients, debug, dbConnection):
    """Search for an address in the SOGo database."""

    try:
        # Nothing found
        if not dbConnection:
            GlobalLogQueue.put("Could not connect to the database")
            return []

        sources = []

        for rec in recipients:
            parts = parse_addr(rec[0])
            uid = parts[0]

            # First, get all the address books from this user
            tablesCursor = dbConnection.cursor()
            abQuery = ("select c_foldername, regexp_replace(c_location, '.*/sogo', 'sogo')"
                       " from sogo_folder_info where"
                       " c_folder_type='Contact' and c_location like '%sogo{}%';".format(uid))

            tablesCursor.execute(abQuery)

            tables = tablesCursor.fetchall()

            # End to search in this address book
            tablesCursor.close()

            # For each table, run a query to check if the address is inside
            for tableInfo in tables:
                abName = tableInfo[0]
                tableName = tableInfo[1]
                cursor = dbConnection.cursor()
                countQuery = "select count(*) from {} where c_content LIKE '%EMAIL%:{}%';".format(tableName, fromAddress)
                if debug:
                    GlobalLogQueue.put("Searching in table {} ({})".format(tableName, abName))
                cursor.execute(countQuery)
                result = cursor.fetchone()
                cursor.close()

                # Store the address book sources when found
                if int(result[0]) > 0:
                    sources.append('SOGo:{}'.format(abName))

        if debug:
            GlobalLogQueue.put("Searched address {} for user {}: {} result(s)".format(
                fromAddress, uid, len(sources)))

    # Make sure to not prevent the message to pass if something happen,
    # but log the error
    except Exception as error:
        GlobalLogQueue.put("Error when searching in address database: {}".format(error.message))

    return sources

class markAddressBookMilter(Milter.Base):

    # A new instance with each new connection.
    def __init__(self):

        # Integer incremented with each call.
        self.id = Milter.uniqueID()

        user = configParser.get('postgres', 'user')
        password = configParser.get('postgres', 'password')
        dbName = configParser.get('postgres', 'dbName')
        connectUrl = "postgresql://{}:{}@127.0.0.1:5432/{}"
        self.dbConnection = psycopg2.connect(connectUrl.format(user, password, dbName))

        self.debug = configParser.getboolean('main', 'debug')

        if self.debug:
            self.queueLogMessage("Running milter address book in debug mode")

        if not self.dbConnection:
            raise "Cannot open SOGo database"

    # Should be executed at the end of a message parsing
    def __exit__(self, exc_type, exc_val, exc_tb):

        if self.debug:
            self.queueLogMessage("Exit from milter address book")

        if self.dbConnection:
            self.dbConnection.close()

    # Each connection runs in its own thread and has its own
    # markAddressBookMilter instance.
    # Python code must be thread safe. This is trivial if only stuff
    # in markAddressBookMilter instances is referenced.
    @Milter.noreply
    def connect(self, hostname, family, hostaddr):
        self.IP = hostaddr[0]
        self.port = hostaddr[1]
        if family == AF_INET6:
            self.flow = hostaddr[2]
            self.scope = hostaddr[3]
        else:
            self.flow = None
            self.scope = None
            self.IPname = hostname    # Name from a reverse IP lookup
            self.H = None
            self.fp = None
            self.receiver = self.getsymval('j')

            if self.debug:
                self.queueLogMessage("connect from {} at {}".format(hostname, hostaddr))

        return Milter.CONTINUE

    def envfrom(self, fromAddress, *extra):
        self.mailFrom = '@'.join(parse_addr(fromAddress))
        self.recipients = []
        self.fromparms = Milter.dictfromlist(extra) # ESMTP parms
        self.user = self.getsymval('{auth_authen}') # authenticated user
        self.fp = StringIO.StringIO()
        return Milter.CONTINUE

    @Milter.noreply
    def envrcpt(self, to, *extra):
        rcptinfo = to, Milter.dictfromlist(extra)
        self.recipients.append(rcptinfo)
        return Milter.CONTINUE

    @Milter.noreply
    def header(self, field, value):
        self.fp.write("{}: {}\n".format(field, value))
        return Milter.CONTINUE

    @Milter.noreply
    def eoh(self):
        self.fp.write("\n")
        return Milter.CONTINUE

    @Milter.noreply
    def body(self, blk):
        self.fp.write(blk)
        return Milter.CONTINUE

    # Add the headers at the eom (End of Message) function.
    # This should work when the recipient is in any of To, CC or BCC headers
    def eom(self):

        # Need to be at the beginning to add headers
        self.fp.seek(0)

        # Include all the sources in the same header, joined by coma
        sources = searchInSOGo(self.mailFrom, self.recipients, self.debug, self.dbConnection)

        if sources:
            self.addheader("X-AddressBook", ','.join(sources))

        return Milter.ACCEPT

    def close(self):
        # always called, even when abort is called. Clean up
        # any external resources here.
        return Milter.CONTINUE

    def abort(self):
        # client disconnected prematurely
        return Milter.CONTINUE

    def queueLogMessage(self, msg):
        GlobalLogQueue.put(msg)


# Background logging thread function
def loggingThread():
    while True:
        entry = GlobalLogQueue.get()
        if entry:
            print(entry)
            sys.stdout.flush()

def main():

    try:
        debug = configParser.getboolean('main', 'debug')

        # Exit if the main thread have been already created
        if os.path.exists(PID_FILE_PATH):
            print("pid file {} already exists, exiting".format(PID_FILE_PATH))
            os.exit(-1)

        lgThread = Thread(target=loggingThread)
        lgThread.start()
        timeout = 600

        # Register to have the Milter factory create new instances
        Milter.factory = markAddressBookMilter

        # For this milter, we only add headers
        flags = Milter.ADDHDRS
        Milter.set_flags(flags)

        # Get the parent process ID and remember it
        pid = os.getpid()
        with open(PID_FILE_PATH, "w") as pidFile:
            pidFile.write(str(pid))
            pidFile.close()

        print("Started address book search and tag milter (pid={}, debug={})".format(pid, debug))
        sys.stdout.flush()

        # Start the background thread
        Milter.runmilter("milter-abook", SOCKET_PATH, timeout)
        GlobalLogQueue.put(None)

        #  Wait until the logging thread terminates
        lgThread.join()

        # Log the end of process
        print("Stopped address book search and tag milter (pid={})".format(pid))

    except Exception as error:
        print("Exception when running the milter: {}".format(error.message))

    # Make sure to remove the pid file even if an error occurs
    # And close the database connection if opened
    finally:
        if os.path.exists(PID_FILE_PATH):
            os.remove(PID_FILE_PATH)

if __name__ == "__main__":
    main()
