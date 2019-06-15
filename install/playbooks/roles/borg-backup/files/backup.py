#!/usr/bin/env python3

'''
This script is a wrapper around borg backup software, heavily specialised for Homebox.
It is not meant to be a general purpose script, as borgbackup is already doing this job very well.

Actually, the script is used to do:

- Regular backups creation called by cron.
- Regular backups verification, called by cron.
- Backup extraction, called after a system re-installation.

The syntax is fairly simple:

The main parameter is --action <ACTION>, It can be:

- init:              Initialise an empty repository.
- backup:            Backup data, but don't check the consistency
- backup-and-check:  Default actkion; init is called before)
- check-data:        Check the consistency of the backup, and verify the content as well
- restore:           Restore the backup to a specific location

usage: backup [-h] --config CONFIG [--key-file KEY_FILE] [--action ACTION]
              [--location LOCATION] [--log-level LOGLEVEL]
              [--log-file LOGFILE]

Backup manager for homebox

optional arguments:
  -h, --help            show this help message and exit
  --config CONFIG       name of the backup configuration to load
  --key-file KEY_FILE   path to the encryption key file
  --action ACTION       What to do: backup; backup-and-check; check-data;
                        init; restore (default=backup-and-check)
  --location LOCATION   Where to restore the backup (only when action=restore;
                        default=/)
  --log-level LOGLEVEL  Log level to use, like DEBUG, INFO, NOTICE, etc. (INFO
                        by default)
  --log-file LOGFILE    Path to the log file (default /var/log/backup.log)

'''

# To parse the initial configuration file
from configparser import ConfigParser

# To parse the initial configuration file
import logging
import argparse
import os
import subprocess
import time

# To parse backup locations
from urllib.parse import urlparse


class BackupManager(object):

    def __init__(self, configName):
        """ Constructor """

        # Global configuration
        self.configName = configName
        self.key = None
        self.repositoryPath = None
        self.repositoryMounted = False
        self.mountPath = None

        # Save backup stdout/stderr for reporting
        # the keys will be create, prune, check or restore
        self.lastBackupInfo = {}

        # Read the domain configuration
        self.config = ConfigParser()
        self.config.read('/etc/homebox/backup.ini')

        # Read default / global configuration
        self.alerts_from = self.config.get('alerts', 'from')
        self.alerts_recipient = self.config.get('alerts', 'recipient')
        self.alerts_jabber = self.config.get('alerts', 'jabber')

        # Read active configuration
        self.url = self.config.get(configName, 'url')
        self.location = urlparse(self.url)

        # Read the compression scheme to use, or use lz4 by default
        self.compression = self.config.get(configName, 'compression')

        # Get frequency options
        self.keepDaily = self.config.get(configName, 'keep_daily')
        self.keepWeekly = self.config.get(configName, 'keep_weekly')
        self.keepMonthly = self.config.get(configName, 'keep_monthly')

        # Check if the backup is active
        self.active = self.config.get(configName, 'active')

        # Save the process information here
        self.runFilePath = '/run/backup-' + self.configName


    # read backup key
    def loadKey(self, path):
        """Loading repository encryption key"""
        try:
            with open(path) as keyFile:
                self.key = keyFile.read()
            logging.info('Successfully loaded encryption key')
            return True
        except:
            logging.warning('Could not load encryption key')
            return False


    # Mount the backup folder, if the location is remote
    def mountRepository(self):
        """Mount the remote location if necessary"""

        ## When using SSH, we do not need to mount remote SSH location.
        # for this scheme, it is assumed that the remote server has borg installed
        # otherwise, use SSHFS
        if self.location.scheme == 'ssh':
            self.repositoryPath = self.url[6:]
            self.repositoryMounted = True
            return True

        # Make sure the directory to mount the backup exists
        self.mountPath = '/mnt/backup/' + self.configName
        os.makedirs(self.mountPath, exist_ok=True)

        # The backup location can be a remote directory mounted locally
        # or even a local partition. This need to be tested thoroughly
        # and might be removed later.
        if self.location.scheme == 'dir':
            self.repositoryPath = self.url[5:]
            self.repositoryMounted = True
            return True

        # The location is a USB device mounted automatically using systemd
        if self.location.scheme == 'usb':
            self.repositoryPath = '/mnt' + self.location.path
            self.mountPath = '/mnt/backup/' + self.configName
            self.repositoryMounted = os.path.ismount(self.mountPath)
            return self.repositoryMounted

        # The location is an S3 bucket mounted automatically using systemd
        if self.location.scheme == 's3fs':
            self.repositoryPath = '/mnt' + self.location.path
            self.mountPath = '/mnt/backup/' + self.configName
            self.repositoryMounted = os.path.ismount(self.mountPath)
            return self.repositoryMounted

        ## When using SSHFS, the remote location is mounted using fuse
        # the mount path and the repository path are the same
        if self.location.scheme == 'sshfs':
            self.repositoryPath = '/mnt/backup/' + self.configName
            self.mountPath = '/mnt/backup/' + self.configName
            self.repositoryMounted = True
            return True

        # Check if the directory is already mounted
        # In this case, we return true, and we will expect the
        # next functions to check if this is a valid repository
        if os.path.ismount(self.mountPath):
            self.repositoryPath = self.mountPath
            self.repositoryMounted = True
            return True

        logging.error("Unknown or not implemented scheme " + self.location)
        raise NotImplementedError(self.location)


    # Umount the remote location
    def umountRepository(self):
        """Umount the remote location if necessary"""
        if not self.repositoryMounted:
            return True

        # Local directories are never mounted
        if self.location.scheme == 'dir' or self.location.scheme == 'ssh':
            self.repositoryPath = None
            self.repositoryMounted = False
            return True

        # umount the current location
        args = [ 'umount', self.mountPath ]

        # Umount the user partition, keep stdout / stderr
        status = subprocess.run(args,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

        if status.returncode != 0:
            logging.error("Error when unmounting the remote repository: " + status.stderr)
            return False

        logging.info('Successfully unmounted directory ' + self.repositoryPath)

        return True


    # Initialise a new repository
    def initRepository(self):
        """Initialise the remote repository using borg init"""

        # This can happen if the repository is already initialised
        # and the script is called with the action set as "init"
        if self.repositoryInitialised():
            return True

        os.environ["BORG_PASSPHRASE"] = self.key

        logging.info("Initialising repository in " + self.repositoryPath)

        args = [ 'borg', 'init' ]

        # Add encryption type: repository key for now
        args.append('--encryption')
        args.append('keyfile')

        # Add repository path
        args.append(self.repositoryPath)

        status = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        if status.returncode != 0:
            logging.error("Error when initialising the repository: " + status.stderr)
            raise RuntimeError(status)

        logging.info("Repository initialised")

        return status.returncode == 0


    # Check if this current backup is active
    def isBackupActive(self):
        return self.active


    # Return true if the manager is configured to send alerts via XMPP
    def sendJabberAlerts(self):
        """Check if the manager is configured to send alerts using XMPP"""
        return self.alerts_jabber


    # Check if this backup is actually running,
    # in this case, exit to avoid two concurrent backups
    def isRunning(self):
        """Check if the content of the PID file in /run/...is my PID"""
        import psutil
        # Check if the running file is here
        try:
            with open(self.runFilePath) as runFile:
                pid = runFile.read()
                logging.info("Backup is marked as running with pid " + pid)
                if psutil.pid_exists(int(pid)):
                    logging.debug("Process {0} found".format(pid))
                    return True
                logging.warning("Process {0} not found".format(pid))
                return False
        except FileNotFoundError as error:
            return False


    def setRunning(self, running):
        """Write my PID in /run/..."""
        if running == True:
            import psutil
            with open(self.runFilePath, 'w') as runFile:
                runFile.write(str(os.getpid()))
        elif os.path.isfile(self.runFilePath):
            os.remove(self.runFilePath)


    # Check if the repository exists
    def repositoryInitialised(self):
        """Check if the repository has been initialised"""

        # Check if the repository exists
        try:
            # If yes, check if it is a borg repository
            os.environ["BORG_PASSPHRASE"] = self.key
            args = [ 'borg', 'list', self.repositoryPath ]
            status = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            logging.info("Initialised the repository." + status.stdout)
        except:
            logging.error("Error when initialising the repository: " + status.stderr)
            return False

        # If not, raise an exception to avoid writing files in a directory with user content
        return status.returncode == 0


    # Create the backup
    def createBackup(self):
        """Create the backup itself"""

        args = [ 'borg', 'create' ]

        # Build repository path specification
        pathSpec = self.repositoryPath + '::homebox-{now}'

        args.append('--filter')
        args.append('AME')

        args.append('--verbose')

        # Check if we compress the content
        if self.compression != None:
            args.append('--compression')
            args.append(self.compression)

        # Exclude some files and directories
        args.append('--exclude-caches')
        args.append('--exclude-from')
        args.append('/etc/homebox/backup-exclude')

        # Reporting
        args.append('--stats')
        args.append('--show-rc')

        args.append(pathSpec)

        # Which paths to backup
        args.append('/home')
        args.append('/var/backups')

        # Start he process
        status = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        if status.returncode == 0:
            self.lastBackupInfo['create'] = "Creation status:\n"
        else:
            self.lastBackupInfo['create'] = "Creation errors:\n"

        # Save details for reporting
        if status.stdout != None:
            self.lastBackupInfo['create'] += status.stdout
        if status.stderr != None:
            self.lastBackupInfo['create'] += status.stderr

        # If not, raise an exception to avoid writing files in a directory
        # that is not a repository
        if status.returncode != 0:
            logging.error("Error when creating backup: " + status.stderr)
            raise RuntimeError(status)

        return status.returncode == 0


    # Create the backup
    def pruneBackup(self):
        """Prune the backup"""

        # Buil repository path specification
        pathSpec = self.repositoryPath

        args = [ 'borg', 'prune' ]

        # Buil repository path specification
        args.append('--prefix')
        args.append('{hostname}-')

        args.append('-v')
        args.append('--list')
        args.append('--stats')

        args.append('--show-rc')

        # Append periodicity
        args.append('--keep-daily')
        args.append(self.keepDaily)
        args.append('--keep-weekly')
        args.append(self.keepWeekly)
        args.append('--keep-monthly')
        args.append(self.keepMonthly)

        # Finally, specify the path
        args.append(pathSpec)

        # Run the process, and keep stdout / stderr
        status = subprocess.run(args,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

        if status.returncode == 0:
            self.lastBackupInfo['prune'] = "Prune status:\n"
        else:
            self.lastBackupInfo['prune'] = "Prune errors:\n"

        # Save details for reporting
        if status.stdout != None:
            self.lastBackupInfo['prune'] += status.stdout
        if status.stderr != None:
            self.lastBackupInfo['prune'] += status.stderr

        # If not, raise an exception to avoid writing files in a directory
        # that is not a repository
        if status.returncode != 0:
            logging.error("Error when pruning backup: " + status.stderr)
            raise RuntimeError(status)

        return status.returncode == 0


    # Check for errors in the backup content
    def checkBackup(self, checkData):
        """Check the backup consistency"""

        # Use the passphrase saved
        os.environ["BORG_PASSPHRASE"] = self.key

        # Standard check
        args = [ 'borg', 'check', '--info' ]

        # Finally add the repository path
        args.append(self.repositoryPath)

        ## Should we check the data as well
        if checkData == True:
            args.append('--verify-data')

        # Star the process and keep stdout / stderr
        status = subprocess.run(args,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

        if status.returncode == 0:
            self.lastBackupInfo['check'] = "Check status:\n"
        else:
            self.lastBackupInfo['check'] = "Check errors:\n"

        # Save details for reporting
        if status.stdout != None:
            self.lastBackupInfo['check'] += status.stdout
        if status.stderr != None:
            self.lastBackupInfo['check'] += status.stderr

        # If not, raise an exception to avoid writing files in a directory
        # that is not a repository
        if status.returncode != 0:
            logging.error("Error when checking backup: " + status.stderr)
            raise RuntimeError(status)

        return status.returncode == 0


    def getLastBackupID(self):
        """Return the last backup ID"""

        # Use the passphrase saved
        os.environ["BORG_PASSPHRASE"] = self.key

        # Standard extractions
        args = [ 'borg', 'list', '--short', '--last', '1']

        # Finally add the repository path
        args.append(self.repositoryPath)

        # Star the process and keep stdout / stderr
        status = subprocess.run(args,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

        # Save details for reporting
        if status.stdout.rstrip() != "":
            return status.stdout.rstrip()
        else:
            return False


    def restoreBackup(self, version, location="/"):
        """Restore the content of the backup to a specific location"""

        # Use the passphrase saved
        os.environ["BORG_PASSPHRASE"] = self.key

        # Change to the target directory
        os.chdir(location)

        # Standard extractions
        args = [ 'borg', 'extract', '--info' ]

        # Add list of restored files
        if args.logLevel == logging.DEBUG:
            args.append('--list')

        # Finally add the repository path
        args.append(self.repositoryPath + "::" + version)

        # Star the process and keep stdout / stderr
        status = subprocess.run(args,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

        if status.returncode == 0:
            self.lastBackupInfo['restore'] = "Restoration status:\n"
        else:
            self.lastBackupInfo['restore'] = "Restoration errors:\n"

        # Save details for reporting
        if status.stdout != None:
            self.lastBackupInfo['restore'] += status.stdout
        if status.stderr != None:
            self.lastBackupInfo['restore'] += status.stderr

        # If not, raise an exception to avoid writing files in a directory
        # that is not a repository
        if status.returncode != 0:
            logging.error("Error when checking backup: " + status.stderr)
            raise RuntimeError(status)

        return status.returncode == 0


    # Send an email if requested
    def sendEmail(self, actionName, success, messages):
        """Send an email with the result of an action using the local mail server"""

        # Import smtplib for the actual sending function
        import smtplib

        # Import the email modules we'll need
        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart

        # Build a simple reporting backup info
        msg = MIMEMultipart()
        subject = 'Backup {0} for {1}: {2}'.format(
            actionName,
            self.configName,
            'Success' if success else 'Error')

        msg.preamble = subject

        for message in messages:
            msg.preamble += "\r\n" + message

        # Add message body
        summary = MIMEText(msg.preamble)
        msg.attach(summary)

        # Add all backup action output / error logs.
        # This can be create, prune, check or restore
        for infoName in self.lastBackupInfo.keys():
            infoReport = MIMEText(self.lastBackupInfo[infoName])
            infoReport.add_header('Content-Disposition', 'inline; filename="{0}.log"'.format(infoName))
            msg.attach(infoReport)

        # This can be used for automatic filtering with Sieve
        msg.add_header('X-Postmaster-Alert', 'backup')

        # Basic headers for the message
        msg['Subject'] = subject
        msg['From'] = self.alerts_from
        msg['To'] = self.alerts_recipient

        # Send the message via our own SMTP server,
        # but don't include the envelope header.
        session = smtplib.SMTP('localhost')
        session.sendmail(self.alerts_from, [ self.alerts_recipient ], msg.as_string())
        session.quit()


    # Send the backup report over XMPP / Jabber
    def sendMessage(self, message):
        """Send instant message using ejabberctl (from postmaster)"""

        args = [ 'ejabberdctl', 'send_message', 'chat' ]

        # Send message text. By default the postmaster account is used
        args.append(self.alerts_from)
        args.append(self.alerts_recipient)

        # No subject for chat messages
        args.append('')

        # Add the message content
        args.append(message)

        # Send the message
        status = subprocess.run(args,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

        # If not, raise an exception to avoid writing files in a directory
        if status.returncode != 0:
            logging.error("Error when sending xmpp message: ", status.stderr)
            raise RuntimeError(status)

        return status == 0



################################################################################
# Entry point
def main(args):

    try:

        success = False
        messages = []

        logging.basicConfig(
            format='%(asctime)s %(levelname)-8s %(message)s',
            datefmt='%a, %d %b %Y %H:%M:%S',
            level=args.logLevel,
            filename=args.logFile
        )

        # Build the manager for this configuration
        manager = BackupManager(args.config)

        # Return if the backup is not active
        if not manager.isBackupActive():
            logging.info("Skipping backup '{0}': Not active".format(args.config))
            return

        # Return if the backup is already running
        if manager.isRunning():
            logging.info("Skipping backup '{0}': already running".format(args.config))
            return

        # Make sure there is only one backup of this configuration at a time
        manager.setRunning(True)

        # This will be used for the short reporting message sent via Jabber
        # or the email message
        if args.action == "init":
            actionName = "Initialisation"
        elif args.action == "backup" or args.action == "backup-and-check":
            actionName = "creation"
        elif args.action == "check-data":
            actionName = "verification"
        else:
            actionName = "restoration"

        # Store the backup starting time
        startTime = time.time()

        # Load the global key encryption key
        manager.loadKey(args.key_file)

        # Mount the remote (or local) repository
        manager.mountRepository()

        # Called to just initialise an empty repository
        if args.action == "init" or not manager.repositoryInitialised():
            manager.initRepository()

        # Create the backup, and prune it
        elif args.action == "backup" or args.action == "backup-and-check":
            manager.createBackup()
            manager.pruneBackup()

        # Should we check the consistency of the backup?
        elif args.action == "backup-and-check":
            manager.checkBackup(False)
        elif args.action == "check-data":
            manager.checkBackup(True)

        # Check if this is a restore attempt
        elif args.action == "restore":
            lastBackupID = manager.getLastBackupID()
            if lastBackupID != False:
                manager.restoreBackup(lastBackupID, args.location)
            else:
                logging.warning("Nothing to restore, backup is empty")

        # unmount the repository as we do not need it anymore
        if not manager.umountRepository():
            messages.append("Warning: could not umount the remote location")

        # Clear up the running flag here, not in the finally block
        # because this block is called if we return because the process
        # is already running
        manager.setRunning(False)

        # Compute the total number of seconds
        duration = round(time.time() - startTime)

        # Will be the email status
        success = True

    except Exception as error:

        logging.error("Exception on running backup: ", error)

        # Unmount the repository if mounted
        if manager.repositoryMounted:
            manager.umountRepository()

        success = False
        messages.append("Exception when running backup, see logs for details")

        # Clear up the running flag here, not in the finally block
        # because this block is called if we return because the process
        # is already running
        manager.setRunning(False)

    finally:

        # Send the email to the postmaster or to an external account
        manager.sendEmail(actionName, success, messages)

        # Exit successfully unless we send the message using Jabber
        if not manager.sendJabberAlerts():
            return

        # Send the messages via Jabber
        if success == True:
            from datetime import timedelta
            durationText = timedelta(seconds=duration)
            status = "Backup {0} finished successfully for '{1}' (duration: {2})".format(
                actionName,
                args.config,
                durationText)
        else:
            status = "Backup {0} failed for '{1}' (See the email for details)".format(
                actionName,
                args.config)

        manager.sendMessage(status)


################################################################################
# parse arguments, build the manager, and call it
# Main call with the arguments
parser = argparse.ArgumentParser(description='Backup manager for homebox')

# Config path argument (mandatory)
parser.add_argument(
    '--config',
    type = str,
    help = 'name of the backup configuration to load',
    required=True)

# Key file for encrypted backup
parser.add_argument(
    '--key-file',
    type = str,
    help = 'path to the encryption key file',
    default = '/etc/homebox/backup-key',
    required=False)

# The action to run
parser.add_argument(
    '--action',
    type = str,
    help = 'What to do: init, backup; backup-and-check (default); check-data; restore',
    default = 'backup-and-check',
    required=False)

# The action to run
parser.add_argument(
    '--location',
    type = str,
    help = 'Where to restore the backup (only when action=restore; default=/)',
    default = '/',
    required=False)

# Log level (DEBUG, INFO, NOTICE, etc..)
parser.add_argument(
    '--log-level',
    dest = 'logLevel',
    type = str,
    default = logging.INFO,
    help = 'Log level to use, like DEBUG, INFO, NOTICE, etc. (INFO by default)')

# Path to the log file
parser.add_argument(
    '--log-file',
    dest = 'logFile',
    type = str,
    default = '/var/log/backup.log',
    help = 'Path to the log file (default /var/log/backup.log)')

args = parser.parse_args()

main(args)
