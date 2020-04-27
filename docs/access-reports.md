# Email access reports

When configured, the users can receive weekly, monthly and yearly reports about their email access. The reports can be
send in plain text, HTML, or both, which is the default option if nothing specified.

- A weekly report is sent every Sunday at midnight, containing the analysis of the previous week.
- A monthly report is sent the first day of every month, containing the analysis of the previous month.
- A yearly report is sent the first day of every year, containing the analysis of the previous year.

The report can contains the following sections:

- Connections per country, if you are travelling.
- Connections per ISP (Internet Service Provider).
- Warned and denied connections.
- Client statistics (Roundcube / SOGo / IMAP)
- Statistics per hour of the day

!!! Note
    This functionality requires the activation of _access check_ option.
    See the [access monitoring page](email-access-monitoring.md) for more details.

## Users selection

By default, only the postmaster and the users specified will receive access reports. This is done in the users section:

```yaml hl_lines="8"
users:
  ...
- uid: leena
  cn: Leena Courtney Makhoul
  first_name: Leena
  last_name: Makhoul
  mail: leena@official.com
  access_report:
    periods: [ 'week', 'month', 'year' ]
    format: 'text'
```

The format option can be 'text', 'html' or 'text,html' or nothing for both.

Then, run the appropriate playbook:

```sh
cd install
ansible-playbook -i ../config/hosts.yml playbooks/access-report.yml
```

!!! Note
    If you remove the option, and run the playbook again, the cron jobs will be removed.

## Report example in text

```txt

Report By ISP
================================================================================
| ISP                     | Country          | From       | Until      | Count |
|-------------------------+------------------+------------+------------+-------|
|        UK Broadband LTE |   United Kingdom | 05 (14:03) | 27 (16:10) |  3131 |
|                  H3G UK |   United Kingdom | 01 (08:23) | 29 (16:21) |  2402 |
|                   LDCOM |           France | 01 (06:23) | 01 (10:28) |   148 |
|         Free Mobile SAS |           France | 09 (11:59) | 10 (16:54) |   141 |
|             Orange S.A. |           France | 01 (12:24) | 01 (12:26) |    48 |
|             EXPONENTIAL |   United Kingdom | 04 (12:51) | 23 (12:08) |    19 |
|             Free Mobile |           France | 26 (07:06) | 26 (07:06) |     1 |
================================================================================


Report by Country
================================================================================
| Country                                    | From       | Until      | Count |
|--------------------------------------------+------------+------------+-------|
|                             United Kingdom | 01 (08:23) | 30 (16:51) |  5654 |
|                                     France | 01 (06:23) | 26 (07:06) |   338 |
================================================================================


Report by Source
================================================================================
| Source                                     | From       | Until      | Count |
|--------------------------------------------+------------+------------+-------|
|                                       imap | 01 (06:23) | 30 (18:38) | 23278 |
|                                  Roundcube | 03 (18:04) | 30 (05:12) |    75 |
|                                       SOGo | 08 (10:06) | 13 (11:48) |     4 |
================================================================================


Report by Hour
================================================================================
|                                 ::                                           |
|                           ::    ::                                           |
|                           ::    ::          ::    ::                         |
|                           ::    ::    ::    ::    ::                         |
|                           ::    ::    ::    ::    ::                         |
|                           ::    ::    ::    ::    ::                         |
|                           ::    ::    ::    ::    ::                         |
|                           ::    ::    ::    ::    ::                         |
|                     ::    ::    ::    ::    ::    ::          ::             |
|                     ::    ::    ::    ::    ::    ::       :: ::             |
|                     ::    ::    ::    ::    ::    ::       :: ::             |
|                     ::    ::    ::    ::    ::    ::    :: :: ::             |
|                  :: ::    ::    ::    ::    ::    ::    :: :: ::             |
|                  :: ::    ::    ::    ::    :: :: :: :: :: :: ::             |
|                  :: ::    ::    :: :: :: :: :: :: :: :: :: :: ::             |
|                  :: :: :: ::    :: :: :: :: :: :: :: :: :: :: ::             |
|                  :: :: :: ::    :: :: :: :: :: :: :: :: :: :: ::             |
|                  :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: ::             |
|                  :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: ::          |
|                  :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: :: ::          |
|------------------------------------------------------------------------------|
|   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23    |
================================================================================

```

## Report example in HTML

<div id="report-sample">
<style>
    table { border: 1px solid #ddd }
    th { padding: 0.2em 1ch }
    table.hour-report * { padding: 0 0 !important }
    tr:nth-child(odd) { background: #eee }
    td.d { background-color:#ddd!important }
    td.l { background-color:#fff!important }
</style>
        <div id="report-isp">
            <h5>Report By ISP</h5>
            <table>
                <tr>
                    <th>ISP</th>
                    <th>Country</th>
                    <th>From</th>
                    <th>Until</th>
                    <th>Count</th>
                </tr>
                <tr>
                    <td><em>UK Broadband LTE</em></td>
                    <td>United Kingdom</td>
                    <td>05 (14:03)</td>
                    <td>27 (16:10)</td>
                    <td>3131</td>
                </tr>
                <tr>
                    <td><em>H3G UK</em></td>
                    <td>United Kingdom</td>
                    <td>01 (08:23)</td>
                    <td>29 (16:21)</td>
                    <td>2402</td>
                </tr>
                <tr>
                    <td><em>LDCOM</em></td>
                    <td>France</td>
                    <td>01 (06:23)</td>
                    <td>01 (10:28)</td>
                    <td>148</td>
                </tr>
                <tr>
                    <td><em>Free Mobile SAS</em></td>
                    <td>France</td>
                    <td>09 (11:59)</td>
                    <td>10 (16:54)</td>
                    <td>141</td>
                </tr>
                <tr>
                    <td><em>Orange S.A.</em></td>
                    <td>France</td>
                    <td>01 (12:24)</td>
                    <td>01 (12:26)</td>
                    <td>48</td>
                </tr>
                <tr>
                    <td><em>EXPONENTIAL</em></td>
                    <td>United Kingdom</td>
                    <td>04 (12:51)</td>
                    <td>23 (12:08)</td>
                    <td>19</td>
                </tr>
                <tr>
                    <td><em>Free Mobile</em></td>
                    <td>France</td>
                    <td>26 (07:06)</td>
                    <td>26 (07:06)</td>
                    <td>1</td>
                </tr>
            </table>
        </div>
        <div id="report-country">
            <h5>Report By Country</h5>
            <table>
                <tr>
                    <th>Country</th>
                    <th>From</th>
                    <th>Until</th>
                    <th>Count</th>
                </tr>
                <tr>
                    <td>United Kingdom</td>
                    <td>01 (08:23)</td>
                    <td>30 (16:51)</td>
                    <td>5654</td>
                </tr>
                <tr>
                    <td>France</td>
                    <td>01 (06:23)</td>
                    <td>26 (07:06)</td>
                    <td>338</td>
                </tr>
            </table>
        </div>
        <div id="report-source">
            <h5>Report By Source</h5>
            <table>
                <tr>
                    <th>Source</th>
                    <th>From</th>
                    <th>Until</th>
                    <th>Count</th>
                </tr>
                <tr>
                    <td>imap</td>
                    <td>01 (06:23)</td>
                    <td>30 (18:38)</td>
                    <td>23278</td>
                </tr>
                <tr>
                    <td>Roundcube</td>
                    <td>03 (18:04)</td>
                    <td>30 (05:12)</td>
                    <td>75</td>
                </tr>
                <tr>
                    <td>SOGo</td>
                    <td>08 (10:06)</td>
                    <td>13 (11:48)</td>
                    <td>4</td>
                </tr>
            </table>
        </div>
        <div id="report-status">
            <h5>Report By Hour</h5>
            <table id="hour-report"><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="d"> </td>
                    <td class="l"> </td>
                    <td class="l"> </td>
                    </tr><tr><th>00</th><th>01</th><th>02</th><th>03</th><th>04</th><th>05</th><th>06</th><th>07</th><th>08</th><th>09</th><th>10</th><th>11</th><th>12</th><th>13</th><th>14</th><th>15</th><th>16</th><th>17</th><th>18</th><th>19</th><th>20</th><th>21</th><th>22</th><th>23</th></tr>
            </table>
        </div>
</div>
