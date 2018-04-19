{% from "scality/settings/definition.jinja" import definition with context %}
configure geo sync:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
{% if definition.georole == "source" %}
    - sls: scality.settings.geosrc
{% elif definition.georole == "destination" %}
    - sls: scality.settings.geodest
{% endif %}

