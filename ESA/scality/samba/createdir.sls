{% from "scality/samba/samba.jinja" import samba with context%}

{%- set sharegroup = grains['scal_share'][0] %}

Empty /tmp/directory_check {{ sharegroup }}:
  file.managed:
    - name: /tmp/directory_check
    - contents:

Refresh grains:
  module.run:
    - name: saltutil.refresh_grains
    - refresh: True


{%- for this in samba.shares %}
{%- if this == sharegroup %}

{%- for grain,args in samba.shares.items() %}
{%- if sharegroup == grain %}
{%- set ext = args[0] %}
{%- set owner = args[1] %}
{%- set sharelist = args[2] %}
{%- set vip = args[3] %}
{% for ip in grains['ip4_interfaces']['fe'] %}
Empty /tmp/directory_check {{ ip }}:
  file.managed:
    - name: /tmp/directory_check
    - contents:
      - ip {{ ip }}

{% if ip == vip %}
{% for directory in sharelist %}
{% set longdir = '/ring/fs/' + directory %}
/tmp/directory_check {{ longdir }}:
  file.append:
    - name: /tmp/directory_check
    - text:
{% if salt['file.directory_exists'](longdir) %}
      - directory {{ longdir }} exist
{% else %}
      - directory {{ longdir }} NOT exist
create dir {{ longdir }}:
  file.directory:
    - name: {{ longdir }}
    - user: {{ owner }}
{%- if sharegroup == 'SCAL_SHARE_DRBK' %}
    - group: archiware
{% else %}
    - group: {{ samba.sharesgroup }} 
{% endif %}
create admin acl {{ longdir }}::
  acl.present:
    - name: {{ longdir }}
    - acl_type: user
    - acl_name: {{ owner }}
    - perms: rwx
{% endif %}
{% endfor %}
{% endif %}

{% endfor %}

{% endif %}
{% endfor %}

{% endif %}
{% endfor %}
