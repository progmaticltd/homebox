# Global sieve script that removed duplicated messages
require [ "duplicate" ];

{% if mail.discard_duplicates %}
# Remove duplicate messages, often
# - when importing the same email more than one time
# - when a mailing list is sending you the same message twice
if duplicate :seconds 60 :header "message-id"
{
  discard;
}
{% endif %}
