#!/usr/bin/env python3

# Gandi DNS manager
# usage: dns-gandi.py [-h] --config CONFIG
#                     [--dkim-public-key-file DKIMPUBLICKEY]
#                     [--log-file LOGFILE] [--log-level LOGLEVEL] [--ip IP]
#                     [--ttl TTL] [--spf-policy {fail,softfail,neutral}]
#                     [--auto-discover {none,thunderbird,outlook,all}]
#                     [--test TEST]

# Gandi DNS updater for homebox

# optional arguments:
#   -h, --help            show this help message and exit
#   --config CONFIG       Location of the config file for the domain you want to
#                         update. This file should contain the API key from Gandi. See below for examples
#   --dkim-public-key-file DKIMPUBLICKEY
#                         Path to the OpenDKIM public key file (not mandatory,
#                         not create a record by default)
#   --log-file LOGFILE    Path to the log file (default /var/log/gandi-dns-
#                         manager.log)
#   --log-level LOGLEVEL  Log level to use, like DEBUG, INFO, NOTICE, etc. (INFO
#                         by default)
#   --ip IP               External IP address (automatically detected by
#                         default)
#   --ttl TTL             TTL value, in seconds, default is set to 3600, i.e.
#                         one hour
#   --spf-policy {fail,softfail,neutral}
#                         Type of SPF record to create (fail by default, i.e.
#                         "-all")
#   --auto-discover {none,thunderbird,outlook,all}
#                         Type of autodiscover entries to create (create all by
#                         default)
#   --test TEST           Testing mode: Create the new version, but does not
#                         activate it
#
# Simplest example of a config file (ini format):
# -----------------------------------------------
# [main]
# provider = gandi
# domain = mydomain.com
#
# [gandi]
# key = JQ50u5Ri8Q9ShsnRzcTeIHTQ
# -----------------------------------------------


# To parse the initial configuration file
from configparser import ConfigParser

import json, datetime, urllib, urllib.request, sys, argparse

import xmlrpc.client

import logging

class GandiDomainManager(object):
    """Gandi DNS manager / manager."""
  
    def __init__(self, configPath):
        """ Constructor """

        self.apikey = None
        self.domain_name = None
        self.zone_id = None
        self.zone_info = None
        self.domain_info = None

        # As soon as a new zone version has been created, this flag is set to True.
        # If an error occurs, the new version will be deleted by a Rollback call
        self.newVersionCreated = False

        # At the end of the call, if this flag is still false,
        # we will delete the new zone version,
        # which is perhaps identical as the current one
        self.modified = False
        
        self.api = xmlrpc.client.ServerProxy('https://rpc.gandi.net/xmlrpc/')
    
        # Read the domain configuration
        config = ConfigParser()
        config.read(configPath)
    
        # Default TTL: 1h
        self.defaultTTL = args.ttl
        
        # Exit if the provider is not Gandi
        provider = config.get('main', 'provider')
        if provider != 'gandi':
            raise "This only works with gandi"
    
        self.domain_name = config.get('main', 'domain')
        self.apikey = config.get('gandi', 'key')
    
        # Create the 'homebox' zone if not exists yet, or get it
        zoneID = "homebox-{0}".format(self.domain_name)
        exists = self.api.domain.zone.count(self.apikey, { 'name': zoneID })
        if exists == 0:
            self.zone_info = self.api.domain.zone.create(self.apikey, { 'name': zoneID })
            self.zone_id = self.zone_info['id']
            self.zone_version = 1
            self.api.domain.zone.set(self.apikey, self.domain_name, self.zone_id)
        else:
            zones = self.api.domain.zone.list(self.apikey, { 'name': zoneID })
            self.zone_info = zones[0]
            self.zone_id = zones[0]['id']
            self.zone_version = zones[0]['version']
            self.api.domain.zone.set(self.apikey, self.domain_name, self.zone_id)

    # Get information methods
    def getDomain(self):
        """Get the current domain associated"""
        return self.domain_name
        
    def isModified(self):
        """Check if the DNS records have been modified"""
        return self.modified
        
    # Read only functions
    def recordExists(self, name, details):
        """Check if a record exists"""
        filter = { 'name': name, 'type': details['type'] }
        count = self.api.domain.zone.record.count(self.apikey, self.zone_id, self.zone_version, filter)
        return (count != 0)

    def getRecordDetails(self, name, details):
        """Get the current value of a record if exists"""
        if self.recordExists(name, details):
            filter = { 'name': name, 'type': details['type'] }
            records = self.api.domain.zone.record.list(self.apikey, self.zone_id, self.zone_version, filter)
            return records[0]
        else:
            return None

    def isDifferent(self, current, new):
        """Compare two records, to check if they are the same before creating a new one.
        return True if the new record is different from the current one"""

        # Update by default
        diff = True

        # Simplest case where we just want to update the TTL value
        if current['ttl'] != new['ttl']:
            return True

        # Simplest records
        if current['type'] == 'A' or current['type'] == 'CNAME' or current['type'] == 'MX':
            diff = current['value'] != new['value']

        # Sanitise TXT and SPF records, otherwise they will be often marked as different,
        # especially long DKIM records, split into multiple chunks
        elif current['type'] == 'TXT' or current['type'] == 'SPF':
            import re
            currentValue = re.sub("[^a-zA-Z0-9]*", "", current['value'])
            newValue = re.sub("[^a-zA-Z0-9]*", "", new['value'])
            print("Current: '{0}'".format(currentValue))
            print("New: '{0}'".format(newValue))
            diff = newValue != currentValue

        return diff

    # Write records methods
    def WriteRecord(self, name, details):
        """Update the whole details of a record"""
        current = self.getRecordDetails(name, details)
        if current is None:
            self.api.domain.zone.record.add(self.apikey, self.zone_id, self.zone_version, details)
            self.modified = True
            logging.info("Created new record for '{0}'".format(name))
        elif self.isDifferent(current, details):
            opts = { 'id': current['id'] }
            self.api.domain.zone.record.update(self.apikey, self.zone_id, self.zone_version, opts, details)
            self.modified = True
            logging.info("Updated record for '{0}'".format(name))
        return self.zone_version

    def WriteARecord(self, name, ipAddress):
        """Create or update an A record"""
        self.WriteRecord(name, {
            'name': name,
            'type': 'A',
            'value': ipAddress,
            'ttl': self.defaultTTL
        })
        return self.zone_version

    def WriteCNameRecord(self, name, value):
        """Create or update a CNAME record"""
        self.WriteRecord(name, {
            'name': name,
            'type': 'CNAME',
            'value': value,
            'ttl': self.defaultTTL
        })
        return self.zone_version

    def WriteMXRecord(self, name, value, priority):
        """Create or update an MX record"""
        self.WriteRecord(name, {
            'name': name,
            'type': 'MX',
            'value': "{0} {1}.{2}.".format(priority, value, self.domain_name),
            'ttl': self.defaultTTL
        })
        return self.zone_version

    def WriteSPFRecords(self, name, spfPolicy):
        """Create or update TXT and SPF records (See RFC 4408 section 3.1.1.)"""
        
        if spfPolicy == 'fail':
            spf = '"v=spf1 mx -all"'
        elif spfPolicy == 'softfail':
            spf = '"v=spf1 mx ~all"'
        elif spfPolicy == 'neutral':
            spf = '"v=spf1 mx ?all"'
            
        # Write the first 'temporary' TXT record
        self.WriteRecord(name, {
            'name': name,
            'type': 'TXT',
            'value': spf,
            'ttl': self.defaultTTL
        })
        
        # Write the second 'standard' SPF record
        self.WriteRecord(name, {
            'name': name,
            'type': 'SPF',
            'value': spf,
            'ttl': self.defaultTTL
        })

        return self.zone_version

    def WriteDKIMRecord(self, selector, content):
        """Create or update TXT record for DKIM"""
        
        # Write the public key content
        name = "{0}._domainkey".format(selector)
        self.WriteRecord(name, {
            'name': name,
            'type': 'TXT',
            'value': content,
            'ttl': self.defaultTTL
        })
        
    # Versions management methods
    def ActivateNewVersion(self):
        """Activate the new version"""
        self.api.domain.zone.version.set(self.apikey, self.zone_id, self.zone_version)

    def CreateNewVersion(self):
        """Create a new zone version for modifications"""
        self.zone_version = self.api.domain.zone.version.new(self.apikey, self.zone_id, self.zone_version)
        self.newVersionCreated = True

    def DeleteNewVersion(self):
        """Delete the current zone version"""
        self.zone_version = self.api.domain.zone.version.delete(self.apikey, self.zone_id, self.zone_version)

    def Rollback(self):
        """Rollback a new version has been created"""
        if self.newVersionCreated:
            self.api.domain.zone.version.delete(self.apikey, self.zone_id, self.zone_version)

def main(args):
    try:
        logging.basicConfig(
            format='%(asctime)s %(levelname)-8s %(message)s',
            datefmt='%a, %d %b %Y %H:%M:%S',
            level=args.logLevel,
            filename=args.logFile
        )

        manager = GandiDomainManager(args.config)

        # Get the external IP address automatically if not provided
        if args.ip != None:
            external_ip = args.ip
        else:
            data = json.loads(urllib.request.urlopen("http://ip.jsontest.com/").read().decode("utf-8"))
            external_ip = data["ip"]
    
        # Check the syntax of the DKIM public key first
        # return if any error occurs
        dkimPublicKey = None
        dkimSelector = None
        if args.dkimPublicKey:
            with open(args.dkimPublicKey) as dkimFile:
                dkimContent = dkimFile.read()
            # Extract the selector name
            end = dkimContent.find('.')
            dkimSelector = dkimContent[0:end]
            # Extract the record content
            begin = dkimContent.find('(')
            end = 1 + dkimContent.find(')')
            dkimPublicKey = dkimContent[begin:end]
            logging.info("Found DKIM record: '{0}'".format(dkimSelector))
        
        # Create a new 'homebox' zone version
        manager.CreateNewVersion()

        # Write an empty record to redirect everything
        manager.WriteARecord('@', external_ip)
        
        # Create or update the default records
        manager.WriteARecord('main', external_ip)
        manager.WriteCNameRecord('webmail', 'main')
        manager.WriteCNameRecord('imap', 'main')
        manager.WriteCNameRecord('smtp', 'main')
        manager.WriteCNameRecord('ldap', 'main')

        # Add the autoconfig entry for Thunderbird
        if args.autoDiscover == 'all' or args.autoDiscover == 'thunderbird':
            manager.WriteCNameRecord('autoconfig', 'main')

        # Add the autodiscover entry for Outlook
        if args.autoDiscover == 'all' or args.autoDiscover == 'outlook':
            manager.WriteCNameRecord('autodiscover', 'main')

        # Create the MX record for mail deliveries
        manager.WriteMXRecord('mx', 'smtp', 5)

        # Create the SPF records
        manager.WriteSPFRecords('@', args.spfPolicy)
        
        # Create the DKIM record
        if dkimPublicKey != None and dkimSelector != None:
            manager.WriteDKIMRecord(dkimSelector, dkimPublicKey)

        # TODO: Create DMARC records

        # Roll back if the new created zone is the same as the current one
        # even in testing mode
        if not manager.isModified():
            logging.info("No modification made, rolling back")
            manager.Rollback()
            return

        # If there is some modification but we are in testing mode,
        # we keep the version but we do not activate it        
        if args.test:
            logging.info("Testing mode, not activating the new zone version")
            return
    
        # Last case: We are not in test mode, and there is changes
        # in the new version, so we activate it
        logging.info("Activating the new zone version")
        manager.ActivateNewVersion()

    # Rollback any change if an error occurs
    except xmlrpc.client.Fault as error:
        logging.error('An error occured using Gandi API : %s ', error)
        manager.Rollback()

# Main call with the arguments
parser = argparse.ArgumentParser(description='Gandi DNS updater for homebox')

# Config path argument (mandatory)
parser.add_argument(
    '--config',
    type = str,
    help = 'Location of the config file for the domain you want to update',
    required=True)

# Path to the OpenDKIM public key file
parser.add_argument(
    '--dkim-public-key-file',
    dest = 'dkimPublicKey',
    type = str,
    help = 'Path to the OpenDKIM public key file (not mandatory, not create a record by default)')

# Path to the log file
parser.add_argument(
    '--log-file',
    dest = 'logFile',
    type = str,
    default = '/var/log/gandi-dns-manager.log',
    help = 'Path to the log file (default /var/log/gandi-dns-manager.log)')

# Log level (DEBUG, INFO, NOTICE, etc..)
parser.add_argument(
    '--log-level',
    dest = 'logLevel',
    type = str,
    default = logging.INFO,
    help = 'Log level to use, like DEBUG, INFO, NOTICE, etc. (INFO by default)')

# External IP address
parser.add_argument(
    '--ip',
    help = 'External IP address (automatically detected by default)')

parser.add_argument(
    '--ttl',
    default = 3600,
    type = int,
    help = 'TTL value, in seconds, default is set to 3600, i.e. one hour')

# SPF record mode: fail / softfail / neutral
parser.add_argument(
    '--spf-policy',
    type = str,
    dest = 'spfPolicy',
    choices = [ 'fail', 'softfail', 'neutral' ],
    default = 'fail',
    help = 'Type of SPF record to create (fail by default, i.e. "-all")')

# Auto discover profile for Thunderbird / Outlook / etc.
parser.add_argument(
    '--auto-discover',
    type = str,
    dest = 'autoDiscover',
    choices = [ 'none', 'thunderbird', 'outlook', 'all' ],
    default = 'all',
    help = 'Type of autodiscover entries to create (create all by default)')


# Testing mode: Create the new version, but does not activate it
parser.add_argument(
    '--test',
    type = bool,
    help = 'Testing mode: Create the new version, but does not activate it')

args = parser.parse_args()

main(args)


