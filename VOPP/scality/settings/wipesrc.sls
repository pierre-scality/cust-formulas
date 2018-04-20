
{% for service in ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd'] %}
stop samba {{ service }}:
  service.dead:
    - name: {{ service }}

stop uwsgi:
  service.dead:
    - name: uwsgi

stop dewpoint:
  service.dead:
   - scality-dewpoint-fcgi.service

{% for dir in ["accepted","shipped" %}:
remove journal  $dir:
  file.absent
{% endfor %}
