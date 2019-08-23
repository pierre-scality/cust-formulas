{% from "scality/samba/samba.jinja" import samba with context%} 

{% for p in samba.services %}
restart samba {{ p }}:
  test.succeed_with_changes:
    - watch_in:
      - service: restart samba {{ p }}
  service.running:
    - name: {{ p }}
    - enable: True
    - reload: True
{% endfor %}

