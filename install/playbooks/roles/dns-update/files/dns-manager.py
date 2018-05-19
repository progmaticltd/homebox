#!/usr/bin/env python3

# To parse the initial configuration file
from configparser import ConfigParser

# To send requests to Gandi API
import xmlrpc.client

import json, sys, argparse

import logging

class DomainManager(object):
    """DNS manager (Gandi only for now)."""

    def __init__(self, configPath):
        """ Constructor """

        # This should be common to all DNS providers
        self.apikey = None
        self.domain_name = None

        # This might be common
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

        # Read the domain configuration
        config = ConfigParser()
        config.read(configPath)

        # Default TTL: 1h
        self.defaultTTL = args.ttl

        ############################################################################
        # Beginning of Gandi specific initialisation

        self.api = xmlrpc.client.ServerProxy('https://rpc.gandi.net/xmlrpc/')

        # Exit if the provider is not Gandi
        provider = config.get('main', 'provider')
        if provider != 'gandi':
            raise "This only works with gandi"

        # Display the domain the part of the key in debug mode
        self.domain_name = config.get('main', 'domain')
        self.apikey = config.get('gandi', 'key')
        logging.debug("Initialising with domain '{0}' and key '{1}".format(
            self.domain_name,
            self.apikey[0:4] + "*" * 20
        ))

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

        # End of Gandi specific initialisation
        ############################################################################


    ############################################################################
    # Begin of Gandi specific

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

    # End of Gandi specific
    ############################################################################

    ############################################################################
    # Generic functions

    # Get information methods
    def getDomain(self):
        """Get the current domain associated"""
        return self.domain_name

    def isModified(self):
        """Check if the DNS records have been modified"""
        return self.modified

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
            diff = newValue != currentValue

        return diff

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
            'value': "{0} {1}".format(priority, value),
            'ttl': self.defaultTTL
        })
        return self.zone_version

    def WriteSRVRecord(self, service, protocol, priority, weight, port, target):
        """Create or update an SRV record"""
        fqdn = "{0}.{1}.".format(target, self.domain_name)
        name = "_{0}._{1}".format(service, protocol)
        self.WriteRecord(name, {
            'name': name,
            'type': 'SRV',
            'value': "{0} {1} {2} {3}".format(priority, weight, port, fqdn),
            'ttl': self.defaultTTL
        })
        return self.zone_version

    def WriteSPFRecords(self, name, spfPolicy, external_ip):
        """Create or update TXT and SPF records (See RFC 4408 section 3.1.1.)"""

        spf = 'v=spf1 mx ip4:{0}/32 '.format(external_ip)
        if spfPolicy == 'fail':
            spf += '-all"'
        elif spfPolicy == 'softfail':
            spf += '~all"'
        elif spfPolicy == 'neutral':
            spf += '?all"'

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


    def WriteDMARCRecord(self):
        """Create or update TXT record for DMARC"""

        # Write the public key content
        name = "_dmarc"

        # Build the content string
        content = "v=DMARC1;"
        content += " p=quarantine;"
        content += " rua=mailto:postmaster@{0};".format(self.domain_name)
        content += " ruf=mailto:postmaster@{0};".format(self.domain_name)
        content += " fo=0;"
        content += " adkim=r;"
        content += " aspf=r;"
        content += " pct=100;"
        content += " rf=afrf;"
        content += " ri=86400"

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

        manager = DomainManager(args.config)

        # Get the external IP address automatically if not provided
        if args.ip != None:
            external_ip = args.ip
        else:
            import json, urllib, urllib.request
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
            begin = 1 + dkimContent.find('(')
            end = dkimContent.find(')')
            dkimPublicKey = dkimContent[begin:end]

            # Remove the extra characters before sending the request to store the value
            import re
            pattern = re.compile('(^\s|\s$)')
            dkimPublicKey = pattern.sub('', dkimPublicKey)
            pattern = re.compile('[\t\n]+')
            dkimPublicKey = pattern.sub('', dkimPublicKey)

            # Debug / Info
            logging.info("Found DKIM record: '{0}'".format(dkimSelector))
            logging.debug("DKIM public key record: '{0}'".format(dkimPublicKey))

        # Create a new 'homebox' zone version
        manager.CreateNewVersion()

        # Write an empty record to redirect everything
        manager.WriteARecord('@', external_ip)

        # Create or update the default records
        manager.WriteARecord('main', external_ip)
        manager.WriteCNameRecord('webmail', 'main')
        manager.WriteCNameRecord('imap', 'main')
        manager.WriteCNameRecord('pop3', 'main')
        manager.WriteCNameRecord('smtp', 'main')
        manager.WriteCNameRecord('ldap', 'main')

        # Add a wildcard record to redirect everything to the same IP address
        manager.WriteCNameRecord('ldap', 'main')

        # Add the autoconfig entry for Thunderbird
        if args.autoDiscover == 'all' or args.autoDiscover == 'thunderbird':
            manager.WriteCNameRecord('autoconfig', 'main')

        # Add the autodiscover entry for Outlook
        if args.autoDiscover == 'all' or args.autoDiscover == 'outlook':
            manager.WriteCNameRecord('autodiscover', 'main')

        # Create a wildcard entry to redirect all traffic to your box
        if args.createWildcard:
            manager.WriteCNameRecord('*', 'main')

        # Create a www entry to host a web site
        if args.createWebEntry:
            manager.WriteCNameRecord('www', 'main')

        # Create the MX record for mail deliveries
        manager.WriteMXRecord('@', 'main', 5)

        # Create the SPF records
        manager.WriteSPFRecords('@', args.spfPolicy, external_ip)

        # Use of SRV Records for Locating Email Submission/Access Services (RFC 6186)
        # Arguments are service, protocol, priority, weight, port, target
        manager.WriteSRVRecord('submission', 'tcp', 0,  0, 587, 'smtp')
        manager.WriteSRVRecord('imaps',      'tcp', 10, 0, 993, 'imap')
        manager.WriteSRVRecord('imap',       'tcp', 10, 0, 143, 'imap')
        manager.WriteSRVRecord('pop3s',      'tcp', 20, 0, 995, 'pop3')
        manager.WriteSRVRecord('pop3',       'tcp', 20, 0, 110, 'pop3')

        # Add SRV and CNAME records for the jabber/xmpp server
        if args.addXMPP:
            manager.WriteCNameRecord('xmpp', 'main')
            manager.WriteCNameRecord('conference', 'main')
            manager.WriteSRVRecord('xmpp-client', 'tcp', 5, 0, 5222, 'xmpp')
            manager.WriteSRVRecord('xmpp-server', 'tcp', 5, 0, 5269, 'xmpp')

        # TODO: Add a backup MX record

        # Create the DKIM record if provided, and then DMARC record
        if dkimPublicKey != None and dkimSelector != None:
            manager.WriteDKIMRecord(dkimSelector, dkimPublicKey)
            manager.WriteDMARCRecord()

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

# Create a www entry, like to host a web site
parser.add_argument(
    '--add-www',
    type = bool,
    dest = 'createWebEntry',
    default = False,
    help = 'Create a www entry to host a web site (default is false)')

# Add a wildcard entry to redirect everything to the same IP address
parser.add_argument(
    '--add-wildcard',
    type = bool,
    dest = 'createWildcard',
    default = False,
    help = 'Add a wildcard entry *.example.com to redirect all traffic to your box (default is false)')

# Create SRV records for the jabber server
parser.add_argument(
    '--add-xmpp',
    type = bool,
    dest = 'addXMPP',
    default = False,
    help = 'Add SRV records for XMPP/Jabber server (default is false)')

# Testing mode: Create the new version, but does not activate it
parser.add_argument(
    '--test',
    type = bool,
    default = True,
    help = 'Testing mode: Create the new version, but does not activate it')

args = parser.parse_args()

main(args)
