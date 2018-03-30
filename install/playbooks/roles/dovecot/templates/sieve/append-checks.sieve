# Global sieve script executed before for user
require [
  "duplicate"
];


{% if mail.discard_duplicates %}
# Remove duplicate messages when importing emails
if duplicate :seconds 60 :header "message-id"
{
  discard;
}
{% endif %}
