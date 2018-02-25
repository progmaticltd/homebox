# Included from top-level .conf file

bind_socket = "localhost:{{ rspamd.proxy.port }}";
type = "proxy";

milter = yes;   # Enable milter mode
timeout = 120s; # Needed for Milter usually

upstream "local" {
  default = yes;
  self_scan = yes;
  hosts = "localhost";
}

count = 1; # Do not spawn too many processes of this type
