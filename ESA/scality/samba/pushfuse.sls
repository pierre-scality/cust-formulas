{% from "scality/samba/samba.jinja" import samba with context%}

{%- set sharegroup = grains['scal_share'][0] %}

{%- for this in samba.shares %}
{%- if this == sharegroup %}

{%- for grain,args in samba.shares.items() %}
{%- if sharegroup == grain %}
{%- set ext = args[0] %}
{%- set adm = args[1] %}
{%- set sharelist = args[2] %}
sfused {{ sharegroup }} :
  file.managed:
    - name: /etc/sfused.conf
    - source: salt://scality/samba/files/sfused.conf.{{ext}}


restart sfused:
  service.running:
    - name: scality-sfused
    - enable: True
    - reload: True
    - watch:
      - file: /etc/sfused.conf

start smbd:
  service.running:
    - name: sernet-samba-smbd
    - enable: True
    - reload: True
    - watch:
      - file: /etc/sfused.conf


{% endif %}
{% endfor %}

{% endif %}
{% endfor %}
