
stop sfull sync d:
  service.dead:
  - name: scality-sfullsyncd-target
  - disable: true

{% for service in ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd'] %}
stop samba {{ service }}:
  service.dead:
    - name: {{ service }}
{% endfor %}

stop dewpoint:
  service.dead:
   - name: scality-dewpoint-fcgi.service


/var/journal:
  file.absent
