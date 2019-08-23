{% from "scality/geo/definition.jinja" import definition with context %}
configure geo connector:
  salt.state:
    - tgt: 'roles:ROLE_GEO'
    - tgt_type: grain
    - sls: scality.geo.geodst

configure cdmi connector:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
    - sls: scality.geo.cdmidst

