{% from "scality/samba/samba.jinja" import samba with context%}

{%- set sharegroup = grains['scal_share'][0] %}

{%- for this in samba.shares %}
{%- if this == sharegroup %}

{%- for grain,args in samba.shares.items() %}
{%- if sharegroup == grain %}
{%- set ext = args[0] %}
{%- set adm = args[1] %}
{%- set sharelist = args[2] %}
smb.conf for {{ sharegroup }}:
  file.managed:
    - name: /etc/samba/smb.conf
    - source: salt://scality/samba/files/smb.conf.tmpl.{{ext}}
    - template: jinja

{% if samba.pushreload == 1 %}
{%- for service in samba.processes %}
reload samba {{ service }} config:
  cmd.run:
    - name: smbcontrol {{ service }}  reload-config
    - onchanges: 
      - file: /etc/samba/smb.conf 
{% endfor %}
{% endif %}

{% endif %}
{% endfor %}

{% endif %}
{% endfor %}
