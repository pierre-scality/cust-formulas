configure geo sync:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
{% if definition.georole == "source" %}
    - sls: scality.settings.src
{% elif definition.georole == "destination" %}
    - sls: scality.settings.geodest
{% endif %}

