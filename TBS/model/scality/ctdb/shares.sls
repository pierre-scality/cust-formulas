{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 
{%- from "scality/map.jinja" import scality with context %}


/etc/samba/smb.conf.d/shares.conf:
  file.managed:
    - contents: |
{%- for share,args in ctdb.shares.items() %}
{%- set path = args[0] %}
{% set members = args[1] %}
        [{{share}}]
        comment = Application {{ share }} share
        path = {{ path }}
        valid users =  {{ members }}
        read only = no
        aio write size = 1
        aio read size = 1
{% endfor %}

