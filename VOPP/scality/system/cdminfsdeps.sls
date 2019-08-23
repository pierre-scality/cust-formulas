{# This script push config to WA the spanning tree boot issue not used anymore #}
{% set sydetc = '/etc/systemd/system' %}
{% if 'ROLE_CONN_CDMI' in grains['roles'] %} 
{% set files = ['scality-dewpoint-fcgi.service'] %}
{% if files is defined %}
{% for file in files %}
{{ file }}:
  file.managed:
    - source: salt://scality/system/files/{{ file }}
    - name: {{ sydetc }}/{{ file }}
    - template: jinja
{% endfor %} 
reload systemd:
  module.run:
  - name: service.systemctl_reload
{% endif %}
{% endif %}
