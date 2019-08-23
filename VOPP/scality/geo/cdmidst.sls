{% from "scality/geo/definition.jinja" import definition with context %}

{{ definition.journaldir }}:
  file.directory

set fuse configuration:
  file.serialize:
    - name: /etc/dewpoint-sofs.js
    - dataset:
        general:
          geosync: false
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion

scality-dewpoint-fcgi.service:
  service.running:
    - restart: true
    - watch:
      - file: /etc/dewpoint-sofs.js

{% for service in ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd'] %}
start samba {{ service }}:
  service.running:
    - name: {{ service }}
    - enable: true
    - watch:
      - file: /etc/dewpoint-sofs.js
{% endfor %}

/tmp/fullsynctemp:
  file.managed:
    - contents:
      - roles {{ definition.georole }} 

