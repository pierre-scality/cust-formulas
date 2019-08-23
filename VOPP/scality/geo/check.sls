{% from "scality/geo/definition.jinja" import definition with context %}

{% if 'ROLE_SVSD' in grains.get('roles') %}
Check svsd:
  module.run:
    - name: service.status
    - m_name: scality-svsd
{% endif %}

{% if 'ROLE_GEO' in grains.get('roles') %}
Check GEO source:
  module.run:
    - name: service.status
    - m_name: uwsgi

Check GEO target:
  module.run:
    - name: service.status
    - m_name: scality-sfullsynd-target
    
Check Journal {{ definition.journaldir }}:
  module.run:
    - name: mount.is_mounted
    - m_name: {{ definition.journaldir }}
{% endif %}

{% if 'ROLE_CONN_CDMI' in grains.get('roles') %}
Check cdmi connector:
  module.run:
    - name: service.status
    - m_name: scality-dewpoint-fcgi

Check Journal {{ definition.journaldir }}:
  module.run:
    - name: mount.is_mounted
    - m_name: {{ definition.journaldir }}
{% endif %}
