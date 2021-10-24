{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 
{%- from "scality/map.jinja" import scality with context %}


{%- set myshare = grains['scal_share'] %}
{%- set mydc = grains['scal_dc'] %}

/etc/samba/smb.conf.d/shares.conf:
  file.managed:
    - contents: |
{%- for sharegrp,shares in ctdb.shares.items() %}
{%- if sharegrp == myshare %}
{%- for share,args in shares.items() %}
{%- set path = args[0] %}
{% set members = args[1] %}
        [{{share}}]
        comment = Application {{ share }} share
        path = {{ path }}
        valid users =  {{ members }}
        read only = no
        aio write size = 1
        aio read size = 1
{%- endfor %}
{%- endif %}
{%- endfor %}

