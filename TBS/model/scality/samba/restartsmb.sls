{% from "scality/samba/samba.jinja" import samba with context%} 

{% for p in samba.processes %}
start samba {{ p }}:
  service.running:
    - name: {{ p }}
    - enable: True
    - reload: True
{% endfor %}

