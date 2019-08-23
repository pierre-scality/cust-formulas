{% from "scality/samba/samba.jinja" import samba with context%} 

/ring/fs/{{ samba.testuser }}:
  file.directory:
    - user: {{ samba.testuser }}
    - group: scality
    - dir_mode: 755 


{%- for srv,args in samba.shares.items() %}
{%- if srv == grains.get('id') %}
{%- set shares = args[0] %}
{%- set members = args[1] %}
{% for share in shares %}
/ring/fs/{{ share }}:
  file.directory

set acl /ring/fs/{{ share }}:
  cmd.run: 
    - name: setfacl -m g:'OPP\domain admins':rwx /ring/fs/{{ share }}

{% endfor %}
{%- endif %}
{%- endfor %}
