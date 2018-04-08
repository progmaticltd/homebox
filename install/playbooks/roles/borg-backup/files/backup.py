#!/usr/bin/env python3

# To parse the initial configuration file
from configparser import ConfigParser

# To parse the initial configuration file
import logging
import argparse
import os
import subprocess

# To parse backup locations
from urllib.parse import urlparse


class BackupManager(object):

    def __init__(self, configName):
        """ Constructor """

        # This should be common to all DNS providers
        self.configName = configName
        self.key = None
        self.repositoryPath = None
        self.repositoryMounted = False
        self.mountPath = None

        # Save backup stdout/stderr for reporting
        self.lastBackupInfo = {}
        self.lastBackupInfo['create'] = None
        self.lastBackupInfo['prune'] = None

        # Read the compression scheme to use, or use lz4 by default
        self.compression = self.config.get(configName, 'compression')

        # Read the domain configuration
        self.config = ConfigParser()
        self.config.read('/etc/homebox/backup.ini')
        self.url = self.config.get(configName, 'url')
        self.location = urlparse(self.url)

        # Get frequency options
        self.keepDaily = self.config.get(configName, 'keep_daily')
        self.keepWeekly = self.config.get(configName, 'keep_weekly')
        self.keepMonthly = self.config.get(configName, 'keep_monthly')

        # Check if the backup is active
        self.active = self.config.get(configName, 'active')

    # read backup key
    def loadKey(self, path):
        """Loading repository encryption key"""
        with open(path) as keyFile:
            self.key = keyFile.read()
        logging.info('Successfully loaded encryption key')

    # Mount the backup folder, if the location is remote
    def mountRepository(self):
        """Mount the remote location if necessary"""
        if self.location.scheme == 'dir':
            self.repositoryPath = self.location.path
            self.repositoryMounted = True
            return True

        # Create a temporary directory to mount the location
        self.mountPath = '/mnt/' + self.configName
        os.makedirs(self.mountPath, exist_ok=True)

        # Check if the directory is already mounted
        # In this case, we return true, and we will expect the
        # next functions to check if this is a valid repository
        if os.path.ismount(self.mountPath):
            logging.warning("Repository already mounted before running the backup")
            self.repositoryPath = self.mountPath
            self.repositoryMounted = True
            return True;

        # Will contains the shell arguments to mount the remote drive
        args = None

        ## Mount: SSH access via sshfs
        if self.location.scheme == 'ssh':
            url = '{0}@{1}:{2}'.format(self.location.username,
                                    self.location.hostname,
                                    self.location.path)
            args = [ 'sshfs', url, self.mountPath ]

        # Mount: smb server via cifs-utils
        elif self.location.scheme == 'smb':
            remoteLocation = '//{0}{1}'.format(self.location.hostname, self.location.path)
            args = [
                'mount', '-t', 'cifs',
                '-o', 'user={0},password={1}'.format(self.location.username, self.location.password),
                remoteLocation, self.mountPath]

        if args == None:
            logging.error("Unknown or not implemented scheme " + self.location)
            raise NotImplementedError(self.location)

        # Mount the backup partition
        status = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if status.returncode != 0:
            logging.error("Error when mounting the remote repository: " + status.stderr)
            raise RuntimeError(status)
        else:
            self.repositoryPath = self.mountPath
            self.repositoryMounted = True

        # Log more details
        logging.info('Successfully mounted remote location: ' + self.url.replace(self.location.password, "***"))
        logging.info('Using directory for remote repository: ' + self.repositoryPath)

        # Return the current status
        return self.repositoryMounted


    # Umount the remote location
    def umountRepository(self):
        """Umount the remote location if necessary"""
        if not self.repositoryMounted:
            return True

        # Local directories are never mounted
        if self.location.scheme == 'dir':
            self.repositoryPath = None
            self.repositoryMounted = False
            return True

        # umount the current location
        args = [ 'umount', self.mountPath ]

        # Umount the user partition
        status = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if status.returncode != 0:
            logging.error("Error when unmounting the remote repository: " + status.stderr)
            return False

        logging.info('Successfully unmounted directory ' + self.repositoryPath)

        return True

    # Check if the repository exists
    def initRepository(self):
        """Initialise the repository"""
        os.environ["BORG_PASSPHRASE"] = self.key

        logging.info("Initialising repository in " + self.repositoryPath)

        args = [ 'borg', 'init', self.repositoryPath ]
        status = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if status.returncode != 0:
            logging.error("Error when initialising the repository: " + status.stderr)
            raise RuntimeError(status)

        logging.info("Repository initialised")
        return status.returncode == 0

    # Check if this current backup is active
    def isBackupActive(self):
        return self.active

    # Check if the repository exists
    def repositoryInitialised(self):
        """Check if the repository has been initialised"""

        # Check if the directory has any content
        files = os.listdir(self.repositoryPath)
        if files == []:
            return False

        # If yes, check if it is a borg repository
        os.environ["BORG_PASSPHRASE"] = self.key
        args = [ 'borg', 'list', self.repositoryPath ]
        status = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # If not, raise an exception to avoid writing files in a directory with user content
        if status.returncode != 0:
            logging.error("Error when initialising the repository: " + status.stderr)
            raise RuntimeError(status)

        return status.returncode == 0


    # Create the backup
    def createBackup(self):
        """Create the backup itself"""

        args = [ 'borg', 'create' ]

        # Build repository path specification
        pathSpec = self.repositoryPath + '::home-{now}'

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

        args.append('/home')

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

        status = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

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

    # Send an email if requested
    def sendEmail(self, success, messages):

        # Import smtplib for the actual sending function
        import smtplib

        # Import the email modules we'll need
        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart

        # Build a simple reporting backup info
        msg = MIMEMultipart()
        msg.preamble = 'Backup report for {0}: {1}'.format(
            self.configName,
            'Success' if success else 'Error')

        for message in messages:
            msg.preamble += "\r\n" + message

        # Add message body
        summary = MIMEText(msg.preamble)
        msg.attach(summary)

        # Add create log (inline)
        if self.lastBackupInfo['create'] != None:
            createReport = MIMEText(self.lastBackupInfo['create'])
            createReport.add_header('Content-Disposition', 'inline; filename="create.log"')
            msg.attach(createReport)

        # Add prune log (inline)
        if self.lastBackupInfo['prune'] != None:
            pruneReport = MIMEText(self.lastBackupInfo['prune'])
            pruneReport.add_header('Content-Disposition', 'inline; filename="prune.log"')
            msg.attach(pruneReport)

        msg['Subject'] = 'Backup report for %s' % self.configName
        msg['From'] = 'root'
        msg['To'] = 'postmaster'

        # Send the message via our own SMTP server,
        # but don't include the envelope header.
        s = smtplib.SMTP('localhost')
        s.sendmail('root', ['postmaster'], msg.as_string())
        s.quit()


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
            return;

        # Load the global key encryption key
        manager.loadKey(args.key_file)

        # Mount the remote (or local) repository
        manager.mountRepository()

        # Initialise if the repository does not exists
        if not manager.repositoryInitialised():
            initialised = manager.initRepository()

        # Create the backup, and prune it
        manager.createBackup()
        manager.pruneBackup()

        # unmount the repository as we do not need it anymore
        if not manager.umountRepository():
            messages.append("Warning: could not umount the remote location")

        # Will be the email status
        success = True

    except Exception as error:

        logging.error("Exception on running backup: ", error)

        # Unmount the repository if mounted
        if manager.repositoryMounted:
            manager.umountRepository()

        success = False
        messages.append("Exception when running backup, see logs for details")

    finally:

        # Send the email to the postmaster
        manager.sendEmail(success, messages)




################################################################################
# parse arguments, build the manager, and call it
# Main call with the arguments
parser = argparse.ArgumentParser(description='Backup manager for borgbackup')

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

# Log level (DEBUG, INFO, NOTICE, etc..)
parser.add_argument(
    '--log-level',
    dest = 'logLevel',
    type = str,
    default = logging.DEBUG,
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
