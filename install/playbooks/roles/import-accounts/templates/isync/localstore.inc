# Local server credentials
IMAPAccount local
Host imap.{{ network.domain }}
User "{{ user.uid }}{{ mail.impersonate.separator }}import"
Pass "{{ import_password }}"
SSLType IMAPS
SSLVersions TLSv1.2

# The local mail store
IMAPStore local
Account local

# Each section should be separated by a blankline,
# so keep this one, or Ansible include
# will remove it and generate error in the confiration file
