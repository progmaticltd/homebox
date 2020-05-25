#!/usr/bin/python3

import sqlite3
import sys
import time
import datetime
import logging
import argparse

# Disable some pylint warnings
# pylint: disable=superfluous-parens
# pylint: disable=line-too-long

# Custom types
from enum import Enum

class Period(Enum):
    lastWeek = 'last-week'
    lastMonth = 'last-month'
    lastYear = 'last-year'
    beginning = 'beginning'
    def __str__(self):
        return self.value

# Exceptions to use
class DatabaseAccessError(Exception):
    """Generated when the IMAP access database cannot be opened"""
    pass

class TemplateError(Exception):
    """Generated when the Jinja template contains an error"""
    pass

class ReportBuilder(object):
    """Build a report for a specific user"""

    def __init__(self, user, period):
        self.mail = "{}".format(user)
        self.home = "/home/users/" + user
        self.secdir = self.home + "/security"
        self.connLogFile = self.secdir + "/imap-connections.db"
        self.sendReport = False
        self.period = period

        # Open the connection
        try:
            self.conn = sqlite3.connect(self.connLogFile)
            if not self.conn:
                raise DatabaseAccessError("Could not open the database '{}'"
                                          .format(self.connLogFile))
        except Exception:
            raise DatabaseAccessError("Could not open the database '{}'"
                                      .format(self.connLogFile))

        logging.info("Opened database successfully")

        # Initialise the period, one month by default
        day = datetime.date.today()
        if period == Period.lastWeek:
            lastWeek = day - datetime.timedelta(days=7)
            self.periodFilter = lastWeek.strftime("%Y-%m-%d")
            self.dateColumns = "strftime('%d (%H:%M)',min(unixtime)),strftime('%d (%H:%M)',max(unixtime))"
        elif period == Period.lastMonth:
            day = day.replace(day=1)
            lastMonth = day - datetime.timedelta(days=1)
            self.periodFilter = lastMonth.strftime("%Y-%m-01")
            self.dateColumns = "strftime('%d (%H:%M)',min(unixtime)),strftime('%d (%H:%M)',max(unixtime))"
        elif period == Period.lastYear:
            day = day.replace(day=1)
            day = day.replace(month=1)
            lastYear = day - datetime.timedelta(days=1)
            self.periodFilter = lastYear.strftime("%Y-01-01")
            self.dateColumns = "strftime('%d/%m', min(unixtime)),strftime('%d/%m', max(unixtime))"
        else:
            self.periodFilter = ""
            self.dateColumns = "strftime('%d/%m/%Y',min(unixtime)),strftime('%d/%m/%Y',max(unixtime))"

        logging.info("Looking for connections > {}".format(self.periodFilter))

    def __exit__(self, exc_type, exc_value, traceback):
        self.conn.close()

    def nbConnections(self):
        """Return the number of connections for this period"""
        condition = "unixtime > '{}%'".format(self.periodFilter)
        cursor = self.conn.execute("select count(*) from connections where {}"
                                   .format(condition))
        count = cursor.fetchone()[0]
        return count

    def updateProviders(self):
        """Update providers from IP addresses, when enpty"""
        import requests
        query = "select distinct(ip) from connections where provider is null;"
        cursor = self.conn.execute(query)
        updates = []

        for row in cursor:
            ip = row[0]
            provider = requests.get('http://ip-api.com/line/{}?fields=isp'
                                    .format(ip)).text.replace("\n", "")
            update = {}
            update['query'] = "update connections set provider=? where ip=?"
            if provider != "":
                update['columns'] = (provider, ip)
            else:
                update['columns'] = ('unknown', ip)
            updates.append(update)
            # Sleep one second to avoid being blacklisted by the server
            time.sleep(1)

        try:
            writeCursor = self.conn.cursor()
            for update in updates:
                writeCursor.execute(update['query'], update['columns'])
            self.conn.commit()
        except Exception:
            raise DatabaseAccessError("Could not open the database '{}' for writing"
                                      .format(self.connLogFile))

    def reportByProvider(self):
        """Get the statistics by ISP (Internet Service Provider)"""
        condition = "unixtime > '{}%' and provider != 'private'".format(self.periodFilter)
        timeColumns = "count(ip) as count," + self.dateColumns
        group = "group by provider"
        order = "order by count desc"
        query = "select provider,countryName,{} from connections where {} {} {}".format(
            timeColumns, condition, group, order)
        cursor = self.conn.execute(query)

        ispReport = []

        for row in cursor:
            line = {}
            line['isp'] = row[0]
            line['country'] = row[1]
            line['nbConnections'] = row[2]
            line['from-date'] = row[3]
            line['till-date'] = row[4]
            ispReport.append(line)

        return ispReport

    # List by country
    def reportByCountry(self):
        """Return per country statistics"""
        condition = "unixtime > '{}%' and countryName != '-'".format(self.periodFilter)
        timeColumns = "count(ip) as count," + self.dateColumns
        group = "group by countryName"
        order = "order by count desc"
        query = "select countryName,{} from connections where {} {} {}".format(
            timeColumns, condition, group, order)
        cursor = self.conn.execute(query)

        countryReport = []

        for row in cursor:
            line = {}
            line['country'] = row[0]
            line['nbConnections'] = row[1]
            line['from-date'] = row[2]
            line['till-date'] = row[3]
            countryReport.append(line)

        return countryReport

    # List by client source
    def reportBySource(self):
        """Return access report by client source (imap, roundcube, ...)"""
        condition = "unixtime > '{}%' and source != '-'".format(self.periodFilter)
        timeColumns = "count(ip) as count," + self.dateColumns
        group = "group by source"
        order = "order by count desc"
        query = "select source,{} from connections where {} {} {}".format(
            timeColumns, condition, group, order)
        cursor = self.conn.execute(query)

        sourceReport = []

        for row in cursor:
            line = {}
            line['source'] = row[0]
            line['nbConnections'] = row[1]
            line['from-date'] = row[2]
            line['till-date'] = row[3]
            sourceReport.append(line)

        return sourceReport


    # List by status
    def reportByStatus(self):
        """Return access by status OK, Warning, Error"""
        condition = "unixtime > '{}%' and status != 'OK'".format(self.periodFilter)
        timeColumns = "count(ip) as count," + self.dateColumns
        group = "group by status,ip"
        order = "order by count desc"
        query = "select status,ip,{} from connections where {} {} {}".format(
            timeColumns, condition, group, order)
        cursor = self.conn.execute(query)

        statusReport = []

        for row in cursor:
            line = {}
            line['status'] = row[0]
            line['ip'] = row[1]
            line['nbConnections'] = row[2]
            line['from-date'] = row[3]
            line['till-date'] = row[4]
            statusReport.append(line)

        return statusReport

    # List by hour
    def reportByHour(self):
        """Return statistics per hour of the day"""
        condition = "unixtime > '{}%'".format(self.periodFilter)
        timeColumns = "strftime('%H', unixtime) as hour,count(*) as count"
        group = "group by hour"
        order = "order by hour"
        query = "select {} from connections where {} {} {}".format(
            timeColumns, condition, group, order)
        cursor = self.conn.execute(query)

        # First pass, get the max value
        hourReport = None
        maxCon = 0
        for row in cursor:
            maxCon = max(maxCon, row[1])

        # Build the hour report only if required
        if maxCon != 0:

            # Initialise the hour report to an array with all possible hours
            hourReport = []
            for h in range(0, 24):
                empty = { 'hour': h, 'count': 0 }
                hourReport.append(empty)

            cursor = self.conn.execute(query)
            for row in cursor:
                line = {}
                hour = int(row[0])
                line['hour'] = hour
                line['count'] = int(20 * int(row[1]) / maxCon)
                hourReport[hour] = line

        return hourReport


def main(args):

    import jinja2
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    # Create the period name
    day = datetime.date.today()
    if args.period == Period.lastWeek:
        lastWeek = day - datetime.timedelta(days=7)
        periodName = lastWeek.strftime("%d/%m/%Y")
        periodTitle = "Weekly"
    elif args.period == Period.lastMonth:
        day = day.replace(day=1)
        lastMonth = day - datetime.timedelta(days=1)
        periodName = lastMonth.strftime("%m/%Y")
        periodTitle = "Monthly"
    elif args.period == Period.lastYear:
        day = day.replace(day=1)
        day = day.replace(month=1)
        lastYear = day - datetime.timedelta(days=1)
        periodName = lastYear.strftime("%Y")
        periodTitle = "Annual"
    else:
        periodName = "Beginning of time"
        periodTitle = "Full"

    user = None
    if args.user:
        user = args.user
    else:
        import getpass
        user = getpass.getuser()

    # The final recipient of the email.
    # When not specified, it will be the user
    recipient = None
    if args.recipient:
        recipient = args.recipient
    else:
        recipient = user

    # Format to use to send the email
    includeText = True
    includeHtml = True
    if args.mailFormat:
        includeText = "text" in args.mailFormat
        includeHtml = "html" in args.mailFormat

    reportBuilder = ReportBuilder(user, args.period)
    if reportBuilder.nbConnections() == 0:
        print("No connections for this period ({})".format(periodName))
        sys.exit()

    # Update providers when they have not been updated
    reportBuilder.updateProviders()

    # Load statistics
    ispReport = reportBuilder.reportByProvider()
    countryReport = reportBuilder.reportByCountry()
    sourceReport = reportBuilder.reportBySource()
    statusReport = reportBuilder.reportByStatus()
    hourReport = reportBuilder.reportByHour()

    # Initialise the mime message
    message = MIMEMultipart("alternative")

    # Create the text template
    if includeText:
        logging.info("Generating a text access report for user {}".format(user))

        textTemplatePath = "/etc/homebox/access-report.d/monthly-report.text.j2"

        try:
            with open(textTemplatePath) as tmplFile:
                template = jinja2.Template(tmplFile.read())

                text = template.render(ispReport=ispReport,
                                       countryReport=countryReport,
                                       sourceReport=sourceReport,
                                       statusReport=statusReport,
                                       hourReport=hourReport).replace("_", " ")

        except Exception:
            raise TemplateError()

        # Attach the text part
        textPart = MIMEText(text, "plain")
        message.attach(textPart)
        logging.info("Generated text message")

    # Create the HTML template
    if includeHtml:
        logging.info("Generating an HTML access report for user {}".format(user))

        htmlTemplatePath = "/etc/homebox/access-report.d/monthly-report.html.j2"

        try:
            with open(htmlTemplatePath) as tmplFile:
                template = jinja2.Template(tmplFile.read())

                html = template.render(ispReport=ispReport,
                                       countryReport=countryReport,
                                       sourceReport=sourceReport,
                                       statusReport=statusReport,
                                       hourReport=hourReport)
        except Exception:
            raise TemplateError()

        # Attach the message
        htmlPart = MIMEText(html, "html")
        message.attach(htmlPart)
        logging.info("Generated html message")

    # Add basic headers
    message["Subject"] = "{} access report for {} ({})".format(periodTitle, user, periodName)
    message["From"] = "postmaster"
    message["To"] = recipient

    # Create secure connection with server and send email
    server = smtplib.SMTP("localhost", 587)
    server.sendmail("postmaster", user, message.as_string())

################################################################################
# parse arguments, build the manager, and call it
# Main call with the arguments

parser = argparse.ArgumentParser(description='IMAP connections reporting tool')

# The user account to inspect
parser.add_argument(
    '--user',
    type=str,
    help="The user to generate the report. Use the current user if not specified",
    required=False)

parser.add_argument(
    '--recipient',
    type=str,
    help="The user to send the report. Use the current user if not specified",
    required=False)

# Format to send the report: html or text. Send both if not specified
parser.add_argument(
    '--format',
    type=str,
    help="Format to send the report: html or text. Send both if not specified",
    dest="mailFormat",
    required=False)

# The period to consider: last month or last year
parser.add_argument(
    '--period',
    type=Period,
    help="The period to use: last-month by default.",
    choices=list(Period),
    required=False)


# Call the entry point
main(parser.parse_args())
