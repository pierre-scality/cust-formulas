{% from "scality/settings/definition.jinja" import definition with context %}
{% set georole = definition.georole %}
wipe current geosync role {{ georole }}:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
{% if georole == "source" %}
    - sls: scality.settings.wipesrc
{% elif georole == "destination" %}
    - sls: scality.settings.wipedest
{% endif %}

