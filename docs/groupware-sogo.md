# Presentation

SOGo is a fully supported and trusted groupware server with a focus on scalability and open standards.

SOGo provides a rich AJAX-based Web interface and supports multiple native clients through the use of standard protocols
such as CalDAV, CardDAV and GroupDAV, as well as Microsoft ActiveSync.

SOGo offers multiple ways to access calendaring and messaging data. Your users can either use a web browser, Microsoft
Outlook, Mozilla Thunderbird, Apple iCal, or a mobile device to access the same information.

# Default settings

These settings are loaded by default when installing SOGo:

```yaml
sogo:
  appointment_send_emails: true
  vacation: true
  forward: true
  sieve_scripts: true
  first_day_of_week: 1 # 1 is Monday
  day_start_time: 9
  day_end_time: 17
  time_format: '%H:%M'
  refresh_view_check: every_minute
  auxiliary_accounts: false
  language: English
  enable_public_access: false
  password_change: true
  auxiliary_accounts: true
```

| Flag                          | Role                                                                                               |
|-------------------------------|----------------------------------------------------------------------------------------------------|
| appointment_send_emails       | Send emails when apointments are created.                                                          |
| vacation                      | Activate vacation functionality in the web interface.                                              |
| forward                       | Activate automatic forward functionality in the web interface.                                     |
| sieve_scripts                 | Allow you to filter your emails using advanced server side filters.                                |
| first_day_of_week             | Set the first day of the week in the interface. Default is Monday, 1. Set it to 0 for Sunday.      |
| day_start_time / day_end_time | The working hours, in 24h notation.                                                                |
| time_format                   | The format used to display the time. See the [strftime](http://strftime.org/) function for format. |
| refresh_view_check            | The time interval to check for new emails.                                                         |
| auxiliary_accounts            | Allow you to retrieve emails from external accounts, directly from the web interface.              |
| language                      | The defaut language of the web interface¹                                                          |
| enable_public_access          | Allow public access to your calendars and address books, using a specific URL.                     |
| password_change               | Allow you to change your passwors from the web interface.                                          |

** Notes **

1. Possible values are defined in the
[SOGo installation guide](https://sogo.nu/files/docs/SOGoInstallationGuide.html#_general_preferences)

# Clients

You can use any client compatible with these standards:

## On Linux

- [Evolution](https://wiki.gnome.org/Apps/Evolution/)
- [Thunderbird](https://www.thunderbird.net/)

## On Windows

- [Thunderbird](https://www.thunderbird.net/)
- [eM Client](https://www.emclient.com/) (Not open source)
- Microsoft Outlook (Not open source)

## On Android

- [DavDroid](https://www.davdroid.com/)
- [CalDAV Sync](https://play.google.com/store/apps/details?id=org.dmfs.caldav.lib)
- [CardDAV sync](https://play.google.com/store/apps/details?id=org.dmfs.carddav.sync)
- [OpenTasks](https://play.google.com/store/apps/details?id=org.dmfs.tasks)

## On MacOS / iOS

- Apple Calendar
- Contacts.app
- [Thunderbird](https://www.thunderbird.net/)
- [eM Client](https://www.emclient.com/)
