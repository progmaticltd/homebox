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
    """Represents valid periods of time"""
    lastWeek = 'last-week'
    lastMonth = 'last-month'
    lastYear = 'last-year'
    beginning = 'beginning'

    def __str__(self):
        return self.value


# Exceptions to use
class DatabaseAccessError(Exception):
    """Generated when the IMAP access database cannot be opened"""


class TemplateError(Exception):
    """Generated when the Jinja template contains an error"""


class ReportBuilder:
    """Build a report for a specific user"""

    def __init__(self, user, period):
        self.mail = "{}".format(user)
        self.home = "/home/users/" + user
        self.secdir = self.home + "/security"
        self.conn_log_file = self.secdir + "/imap-connections.db"
        self.send_report = False
        self.period = period

        # Open the connection
        try:
            self.conn = sqlite3.connect(self.conn_log_file)
            if not self.conn:
                raise DatabaseAccessError("Could not open the database '{}'"
                                          .format(self.conn_log_file))
        except Exception:
            raise DatabaseAccessError("Could not open the database '{}'"
                                      .format(self.conn_log_file))

        logging.info("Opened database successfully")

        # Initialise the period, one month by default
        day = datetime.date.today()
        if period == Period.lastWeek:
            last_week = day - datetime.timedelta(days=7)
            self.period_filter = last_week.strftime("%Y-%m-%d")
            self.date_columns = "strftime('%d (%H:%M)',min(unixtime)),strftime('%d (%H:%M)',max(unixtime))"
        elif period == Period.lastMonth:
            day = day.replace(day=1)
            last_month = day - datetime.timedelta(days=1)
            self.period_filter = last_month.strftime("%Y-%m-01")
            self.date_columns = "strftime('%d (%H:%M)',min(unixtime)),strftime('%d (%H:%M)',max(unixtime))"
        elif period == Period.lastYear:
            day = day.replace(day=1)
            day = day.replace(month=1)
            last_year = day - datetime.timedelta(days=1)
            self.period_filter = last_year.strftime("%Y-01-01")
            self.date_columns = "strftime('%d/%m', min(unixtime)),strftime('%d/%m', max(unixtime))"
        else:
            self.period_filter = ""
            self.date_columns = "strftime('%d/%m/%Y',min(unixtime)),strftime('%d/%m/%Y',max(unixtime))"

        logging.info("Looking for connections > %s", self.period_filter)

    def __exit__(self, exc_type, exc_value, traceback):
        self.conn.close()

    def nb_connections(self):
        """Return the number of connections for this period"""
        condition = "unixtime > '{}%'".format(self.period_filter)
        cursor = self.conn.execute("select count(*) from connections where {}"
                                   .format(condition))
        count = cursor.fetchone()[0]
        return count

    def update_providers(self):
        """Update providers from IP addresses, when enpty"""
        import requests
        query = "select distinct(ip) from connections where provider is null;"
        cursor = self.conn.execute(query)
        updates = []

        for row in cursor:
            remote_ip = row[0]
            provider = requests.get('http://ip-api.com/line/{}?fields=isp'
                                    .format(remote_ip)).text.replace("\n", "")
            update = {}
            update['query'] = "update connections set provider=? where ip=?"
            if provider != "":
                update['columns'] = (provider, remote_ip)
            else:
                update['columns'] = ('unknown', remote_ip)
            updates.append(update)
            # Sleep one second to avoid being blacklisted by the server
            time.sleep(1)

        try:
            write_cursor = self.conn.cursor()
            for update in updates:
                write_cursor.execute(update['query'], update['columns'])
            self.conn.commit()
        except Exception:
            raise DatabaseAccessError("Could not open the database '{}' for writing"
                                      .format(self.conn_log_file))

    def report_by_provider(self):
        """Get the statistics by ISP (Internet Service Provider)"""
        condition = "unixtime > '{}%' and provider != 'private'".format(self.period_filter)
        time_columns = "count(ip) as count," + self.date_columns
        group = "group by provider"
        order = "order by count desc"
        query = "select provider,countryName,{} from connections where {} {} {}".format(
            time_columns, condition, group, order)
        cursor = self.conn.execute(query)

        isp_report = []

        for row in cursor:
            line = {}
            line['isp'] = row[0]
            line['country'] = row[1]
            line['nb_connections'] = row[2]
            line['from-date'] = row[3]
            line['till-date'] = row[4]
            isp_report.append(line)

        return isp_report

    # List by country
    def report_by_country(self):
        """Return per country statistics"""
        condition = "unixtime > '{}%' and countryName != '-'".format(self.period_filter)
        time_columns = "count(ip) as count," + self.date_columns
        group = "group by countryName"
        order = "order by count desc"
        query = "select countryName,{} from connections where {} {} {}".format(
            time_columns, condition, group, order)
        cursor = self.conn.execute(query)

        country_report = []

        for row in cursor:
            line = {}
            line['country'] = row[0]
            line['nb_connections'] = row[1]
            line['from-date'] = row[2]
            line['till-date'] = row[3]
            country_report.append(line)

        return country_report

    # List by client source
    def report_by_source(self):
        """Return access report by client source (imap, roundcube, ...)"""
        condition = "unixtime > '{}%' and source != '-'".format(self.period_filter)
        time_columns = "count(ip) as count," + self.date_columns
        group = "group by source"
        order = "order by count desc"
        query = "select source,{} from connections where {} {} {}".format(
            time_columns, condition, group, order)
        cursor = self.conn.execute(query)

        source_report = []

        for row in cursor:
            line = {}
            line['source'] = row[0]
            line['nb_connections'] = row[1]
            line['from-date'] = row[2]
            line['till-date'] = row[3]
            source_report.append(line)

        return source_report

    # List by status
    def report_by_status(self):
        """Return access by status OK, Warning, Error"""
        condition = "unixtime > '{}%' and status != 'OK'".format(self.period_filter)
        time_columns = "count(ip) as count," + self.date_columns
        group = "group by status,ip"
        order = "order by count desc"
        query = "select status,ip,{} from connections where {} {} {}".format(
            time_columns, condition, group, order)
        cursor = self.conn.execute(query)

        status_report = []

        for row in cursor:
            line = {}
            line['status'] = row[0]
            line['ip'] = row[1]
            line['nb_connections'] = row[2]
            line['from-date'] = row[3]
            line['till-date'] = row[4]
            status_report.append(line)

        return status_report

    # List by hour
    def report_by_hour(self):
        """Return statistics per hour of the day"""
        condition = "unixtime > '{}%'".format(self.period_filter)
        time_columns = "strftime('%H', unixtime) as hour,count(*) as count"
        group = "group by hour"
        order = "order by hour"
        query = "select {} from connections where {} {} {}".format(
            time_columns, condition, group, order)
        cursor = self.conn.execute(query)

        # First pass, get the max value
        hour_report = None
        max_connect = 0
        for row in cursor:
            max_connect = max(max_connect, row[1])

        # Build the hour report only if required
        if max_connect != 0:

            # Initialise the hour report to an array with all possible hours
            hour_report = []
            for hour in range(0, 24):
                empty = {'hour': hour, 'count': 0}
                hour_report.append(empty)

            cursor = self.conn.execute(query)
            for row in cursor:
                line = {}
                hour = int(row[0])
                line['hour'] = hour
                line['count'] = int(20 * int(row[1]) / max_connect)
                hour_report[hour] = line

        return hour_report


def get_period_details(period, day):

    if period == Period.lastWeek:
        last_week = day - datetime.timedelta(days=7)
        period_filter = last_week.strftime("%d/%m/%Y")
        period_title = "Weekly"
    elif period == Period.lastMonth:
        day = day.replace(day=1)
        last_month = day - datetime.timedelta(days=1)
        period_filter = last_month.strftime("%m/%Y")
        period_title = "Monthly"
    elif period == Period.lastYear:
        day = day.replace(day=1)
        day = day.replace(month=1)
        last_year = day - datetime.timedelta(days=1)
        period_filter = last_year.strftime("%Y")
        period_title = "Annual"
    else:
        period_filter = "Beginning of time"
        period_title = "Full"

    return (period_title, period_filter)


def main(args):
    """Program entry point"""
    import jinja2
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    # Get the period name and filter from the command line arguments
    day = datetime.date.today()
    period_title, period_filter = get_period_details(args.period, day)

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
    include_text = True
    include_html = True
    if args.mailFormat:
        include_text = "text" in args.mailFormat
        include_html = "html" in args.mailFormat

    report_builder = ReportBuilder(user, args.period)
    if report_builder.nb_connections() == 0:
        print("No connections for this period ({})".format(period_filter))
        sys.exit()

    # Update providers when they have not been updated
    report_builder.update_providers()

    # Load statistics
    isp_report = report_builder.report_by_provider()
    country_report = report_builder.report_by_country()
    source_report = report_builder.report_by_source()
    status_report = report_builder.report_by_status()
    hour_report = report_builder.report_by_hour()

    # Initialise the mime message
    message = MIMEMultipart("alternative")

    # Create the text template
    if include_text:
        logging.info("Generating a text access report for user %s", user)

        text_template_path = "/etc/homebox/access-report.d/monthly-report.text.j2"

        try:
            with open(text_template_path) as tmpl_file:
                template = jinja2.Template(tmpl_file.read())

                text = template.render(isp_report=isp_report,
                                       country_report=country_report,
                                       source_report=source_report,
                                       status_report=status_report,
                                       hour_report=hour_report).replace("_", " ")

        except Exception:
            raise TemplateError()

        # Attach the text part
        text_part = MIMEText(text, "plain")
        message.attach(text_part)
        logging.info("Generated text message")

    # Create the HTML template
    if include_html:
        logging.info("Generating an HTML access report for user %s", user)

        html_template_path = "/etc/homebox/access-report.d/monthly-report.html.j2"

        try:
            with open(html_template_path) as tmpl_file:
                template = jinja2.Template(tmpl_file.read())

                html = template.render(isp_report=isp_report,
                                       country_report=country_report,
                                       source_report=source_report,
                                       status_report=status_report,
                                       hour_report=hour_report)
        except Exception:
            raise TemplateError()

        # Attach the message
        html_part = MIMEText(html, "html")
        message.attach(html_part)
        logging.info("Generated html message")

    # Add basic headers
    message["Subject"] = "{} access report for {} ({})".format(period_title, user, period_filter)
    message["From"] = "postmaster"
    message["To"] = recipient

    # Create secure connection with server and send email
    server = smtplib.SMTP("localhost", 587)
    server.sendmail("postmaster", user, message.as_string())

################################################################################
# parse arguments, build the manager, and call it
# Main call with the arguments


PARSER = argparse.ArgumentParser(description='IMAP connections reporting tool')

# The user account to inspect
PARSER.add_argument(
    '--user',
    type=str,
    help="The user to generate the report. Use the current user if not specified",
    required=False)

PARSER.add_argument(
    '--recipient',
    type=str,
    help="The user to send the report. Use the current user if not specified",
    required=False)

# Format to send the report: html or text. Send both if not specified
PARSER.add_argument(
    '--format',
    type=str,
    help="Format to send the report: html or text. Send both if not specified",
    dest="mailFormat",
    required=False)

# The period to consider: last month or last year
PARSER.add_argument(
    '--period',
    type=Period,
    help="The period to use: last-month by default.",
    choices=list(Period),
    required=False)


# Call the entry point
main(PARSER.parse_args())
