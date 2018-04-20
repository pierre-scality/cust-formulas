{% from "scality/settings/definition.jinja" import definition with context %}

{% for service in ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd'] %}
stop samba {{ service }}:
  service.dead:
    - name: {{ service }}
{% endfor %}

stop uwsgi:
  service.dead:
    - name: uwsgi

stop dewpoint:
  service.dead:
   - name: scality-dewpoint-fcgi.service

{% for dir in ["accepted","shipped"] %}
remove journal {{ dir }}:
  file.absent:
    - name: {{ definition.journaldir }}/{{ dir }}
{% endfor %}
