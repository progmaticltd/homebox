# Included from top-level .conf file

type = "controller";
count = 1;
secure_ip = "127.0.0.1";
secure_ip = "::1";
static_dir = "${WWWDIR}";

bind_socket = "/run/rspamd/controller.sock mode=0666 owner=_rspamd";

password = "{{ rspamd_password }}";
enable_password = "{{ rspamd_password }}";
