#!/usr/bin/env python3

# Simplified Python example to find contacts which are not created/managed by the reseller
# Replace your-api-key with your API Key: https://wiki.gandi.net/en/xml-api

from configparser import ConfigParser

import json, datetime, urllib, urllib.request, sys, getopt

import xmlrpc.client

import logging

record = { 'type':'A', 'name':'@' }

LOG_LEVEL = logging.DEBUG
LOG_FILE = '/tmp/dns-gandy.log'

class GandiDomainManager(object):
    """Gandi DNS manager / manager."""
  
    def __init__(self):
        """ Constructor """
        self.defaultTTL = 3600
        
        self.apikey = None
        self.domain_name = None
        self.zone_id = None
        self.zone_info = None
        self.domain_info = None

        # At the end of the call, if this flag is still false,
        # we will delete the new zone version,
        # which is perhaps identical as the current one
        self.modified = False
        
        self.api = xmlrpc.client.ServerProxy('https://rpc.gandi.net/xmlrpc/')
    
        # Read the domain configuration
        config = ConfigParser()
        config.read('/etc/homebox/dns-config.ini')
    
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
    def recordExists(self, name):
        """Check if a record exists"""
        filter = { 'name': name }
        count = self.api.domain.zone.record.count(self.apikey, self.zone_id, self.zone_version, filter)
        return (count != 0)

    def getRecordDetails(self, name):
        """Get the current value of a record if exists"""
        if self.recordExists(name):
            filter = { 'name': name }
            records = self.api.domain.zone.record.list(self.apikey, self.zone_id, self.zone_version, filter)
            return records[0]
        else:
            return None

    # Write functions
    def WriteRecord(self, name, details):
        """Update the whole details of a record"""
        current = self.getRecordDetails(name)
        if current is None:
            self.api.domain.zone.record.add(self.apikey, self.zone_id, self.zone_version, details)
            self.modified = True
        elif current['value'] != details['value']:
            opts = { 'id': current['id'] }
            self.api.domain.zone.record.update(self.apikey, self.zone_id, self.zone_version, opts, details)
            self.modified = True
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

    def WriteSPFRecords(self, name = '@', strict = True):
        """Create or update an SPF record (See RFC 4408 section 3.1.1.)"""
        if strict:
            spf = "v=spf1 mx -all"
        else:
            spf = "v=spf1 mx ~all"
            
        # Write the first temporary 'TXT' record
        self.WriteRecord(name, {
            'name': name,
            'type': 'TXT',
            'value': spf,
            'ttl': self.defaultTTL
        })
        
        # Write the second real 'SPF' record
        self.WriteRecord(name, {
            'name': name,
            'type': 'SPF',
            'value': spf,
            'ttl': self.defaultTTL
        })

        return self.zone_version

    def ActivateNewVersion(self):
        """Activate the new version"""
        self.api.domain.zone.version.set(self.apikey, self.zone_id, self.zone_version)

    def CreateNewVersion(self):
        """Create a new zone version for modifications"""
        self.zone_version = self.api.domain.zone.version.new(self.apikey, self.zone_id, self.zone_version)

    def DeleteNewVersion(self):
        """Delte the current zone version"""
        self.zone_version = self.api.domain.zone.version.delete(self.apikey, self.zone_id, self.zone_version)

def main(argv):
    try:
        logging.basicConfig(
            format='%(asctime)s %(levelname)-8s %(message)s',
            datefmt='%a, %d %b %Y %H:%M:%S',
            level=LOG_LEVEL,
            filename=LOG_FILE
        )
    
        manager = GandiDomainManager()

        # Get the external IP address
        # TODO: Use a library
        data = json.loads(urllib.request.urlopen("http://ip.jsontest.com/").read().decode("utf-8"))
        external_ip = data["ip"]
    
        # Create a new zone version
        manager.CreateNewVersion()
        
        # Create or update the default records
        manager.WriteARecord('main', external_ip)
        manager.WriteCNameRecord('webmail', 'main')
        manager.WriteCNameRecord('imap', 'main')
        manager.WriteCNameRecord('smtp', 'main')
        manager.WriteCNameRecord('ldap', 'main')

        # Create the MX record for mail deliveries
        manager.WriteMXRecord('smtp', 'smtp', 5)

        # Create the SPF records
        manager.WriteSPFRecords('@')
    
        # Activate the new version
        if manager.isModified():
            print("Activating the zone version")
            manager.ActivateNewVersion()
        else:
            print("No modification made, rolling back")
            manager.DeleteNewVersion()

    except xmlrpc.client.Fault as e:
        logging.error('An error occured using Gandi API : %s ', e)
        manager.DeleteNewVersion()

main(sys.argv)


