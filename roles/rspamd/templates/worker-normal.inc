# Included from top-level .conf file

type = "normal";
mime = true;
task_timeout = 8s;

# bind_socket = "localhost:{{ rspamd.normal.port }}";
bind_socket = "/run/rspamd/worker.sock mode=0660 owner=_rspamd group=_rspamd ";
