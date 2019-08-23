{% from "scality/geo/definition.jinja" import definition with context %}
configure geo connector:
  salt.state:
    - tgt: 'roles:ROLE_GEO'
    - tgt_type: grain
{% if definition.georole == "source" %}
    - sls: scality.geo.geosrc
{% elif definition.georole == "destination" %}
    - sls: scality.geo.geodst
{% endif %}

configure cdmi connector:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
{% if definition.georole == "source" %}
    - sls: scality.geo.cdmisrc
{% elif definition.georole == "destination" %}
    - sls: scality.geo.cdmidst
{% endif %}

