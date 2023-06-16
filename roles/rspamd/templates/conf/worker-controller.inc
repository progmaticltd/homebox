# Included from top-level .conf file

type = "controller";
count = 1;
secure_ip = "127.0.0.1";
secure_ip = "::1";
static_dir = "${WWWDIR}";

# Postfix has been added to the rspamd group
bind_socket = "/run/rspamd/controller.sock mode=0660 owner=_rspamd group=mail_users";

password = "{{ rspamd_password }}";
enable_password = "{{ rspamd_password }}";
