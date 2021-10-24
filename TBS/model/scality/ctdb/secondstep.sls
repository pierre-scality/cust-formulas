{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 
{%- from "scality/map.jinja" import scality with context %}



{%- for svc,svclist in ctdb.ctdbsvc.items() %}
{%- if svc == ctdb.ctdbtype %} 
{%- for helper in svclist %}
run helper {{ helper }}:
  cmd.run:
    - name: ctdb event script enable legacy {{ helper }}
{% endfor %}
{% endif %}
{% endfor %}

restart_ctd_svc:
  test.succeed_with_changes:
    - watch_in:
      - service: restart_ctd_svc
  service.running:
  - name: sernet-samba-ctdbd
  - enable: true
