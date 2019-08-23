{% from "scality/settings/definition.jinja" import definition with context %}
configure geo connector:
  salt.state:
    - tgt: 'roles:ROLE_GEO'
    - tgt_type: grain
{% if definition.georole == "source" %}
    - sls: scality.settings.geosrc
{% elif definition.georole == "destination" %}
    - sls: scality.settings.geodst
{% endif %}

configure cdmi connector:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
{% if definition.georole == "source" %}
    - sls: scality.settings.cdmisrc
{% elif definition.georole == "destination" %}
    - sls: scality.settings.cdmidst
{% endif %}

