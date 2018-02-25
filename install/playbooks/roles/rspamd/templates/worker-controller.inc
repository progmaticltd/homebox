# Included from top-level .conf file

type = "controller";
count = 1;
password = "q1";
secure_ip = "127.0.0.1";
secure_ip = "::1";
static_dir = "${WWWDIR}";

password = "{{ rspamd_password_fact.stdout }}";
enable_password = "{{ rspamd_password_fact.stdout }}";
bind_socket = "localhost:{{ rspamd.controller.port }}";