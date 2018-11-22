# Presentation

SOGo is a fully supported and trusted groupware server with a focus on
scalability and open standards.

SOGo provides a rich AJAX-based Web interface and supports multiple
native clients through the use of standard protocols such as CalDAV,
CardDAV and GroupDAV, as well as Microsoft ActiveSync.

SOGo offers multiple ways to access calendaring and messaging
data. Your users can either use a web browser, Microsoft Outlook,
Mozilla Thunderbird, Apple iCal, or a mobile device to access the same
information.

# Default settings

These settings are loaded by default when installing SOGo:

```yaml
# Default settings for SOGo groupware
sogo:
  appointment_send_email_notifications: true
  vacation: true
  forward: true
  sieve_scripts: true
  first_day_of_week: 1
  refresh_view_check: manually
  mail_auxiliary_accounts: false
```
