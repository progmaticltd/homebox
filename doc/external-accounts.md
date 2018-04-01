# Downloading emails from external accounts

It is possible to add external accounts (GMail, Outlook, Yahoo, IMAP, etc...) to the platform.
In this case, your emails will be downloaded in background, every time you logon on your account.

_This is a one way synchronisation only, the remote accounts are not modified._

## Security

The credentials and the settings are stored on your box only, encrypted with AES 256 bits scheme.
The description key is stored by the root account. The credentials are decrypted by the user account
and kept in memory during the synchronisation process.

Behind the scene, the platform is using [isync](http://isync.sourceforge.net/mbsync.html).

Whatever you access your account using the webmail or using an email client, the emails from other accounts will be
downloaded transparently.

The folders hierarchy is reproduced on your server, with some adaptations for GMail, though.

## Notes

- The emails will be imported once only. The system is keeping a record of the emails indexes already imported.
- If you set up multiple external accounts, they will be all downloaded in parallel.
- The next version will add cron synchronisation, at office hours, etc.

## Example

Below is an example for one user named "andre", with multiple external accounts:

```
users:
- uid: andre
  cn: André Rodier
  first_name: André
  last_name: Rodier
  mail: andre@homebox.space
  password: ioherin937aaf
  aliases:
    - andré@homebox.space
    - andy@homebox.space
    - andrew@homebox.space
  external_accounts:
    - name: work
      type: imap
      host: imap.company.com
      user: arodier
      password: 'Imlirhf*62e3'
      max_messages: 10
    - name: zoho
      type: imap
      host: imappro.zoho.com
      user: andre@rodier.me
      password: 'mt6wiu*VFkjv'
      max_messages: 10
      get_junk: true
    - name: gmail
      type: gmail
      user: arodier427@gmail.com
      password: bqlcmryyxswmvofw
      get_important: false
      get_junk: true
      get_trash: true
      max_messages: 10
    - name: yahoo
      type: ymail
      user: arodier666@ymail.com
      password: pkxzibnnzakbizvq
      get_junk: true
      get_trash: true
      max_messages: 10
    - name: outlook
      type: live.com
      user: jbond007@live.co.uk
      password: uqspxcsghssipmfw
      get_junk: true
      get_trash: true
      max_messages: 10
```
## Details of the options

There are a few options to download emails detailled below.

### Server name: "name"

The name option is used to keep track of your email synchronisation state. It is totally arbitrary, although
it is better to keep a logic name. This is mandatory.

### Specify the server type: "type"

The type option is mandatory, and represents some pre-recorded settings to import your email.

It can be for instance "gmail", "<span>live</span>.com", "ymail" (Yahoo), or plain IMAP.

If you are using IMAP, you will have to specify the server address.

The import system will try SSL and TLS for connection.


### Synchronise Junk emails too: "get_junk"

If you want to import and keep synchronised Junk/Spam emails too, set this option to true.
It is set to false by default.


### Synchronise Trash/Bin emails too: get_trash

If you do not want to import delete emails too, set this option to false. It is set to true by default.

### Testing the synchronisation: "max_messages"

This option is useful if you want to test the import / synchronisation, and see how the folders will be synchronised.
In the example above, the system downloads the last 10 emails, but will reproduce the entire folders hierarchy.

# Special cases

## GMail

Google Mail (aka GMail) has some specific features, that make the import trickier.
However, the system makes some choice.
For instance, the folders hierarchy is reproduced, but without the ugly '[Google Mail]' label.

- [Google Mail]/Sent Mail : /Sent
- [Google Mail]/Drafts : /Draft
- [Google Mail]/Archives : /Archives
- [Google Mail]/Bin : /Trash
- [Google Mail]/Spam : /Junk
- [Google Mail]/Chat : Not synchronised.
- [Google Mail]/Starred : Not synchronised.
- [Google Mail]/Important : Optionally synchronised.

The "Starred" folder is a virtual folder that represents a view of your starred emails.
The same behaviour will be added to this platform.

Since Google Mail has merged IMAP folders and labels, some emails will be imported multiple times,
into multiple folders, if they have multiple labels.
There is nothing to do - yet - about this, but it is better to import an email multiple times rather than
loosing emails.

### Get important emails in a specific folder

As a corollary, there is an option, specific to GMail, to download the emails marked as "Important" in
a dedicated folder, the option is called "`get_important`", and set to true by default.

### Get archives: "get_archives"

This option is set to true by default. Set it to false if you do not want to download your entire email
archives.

_Be careful, some email providers will not let you download emails once archived, for instance Zoho._
