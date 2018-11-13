{% from "scality/samba/samba.jinja" import samba with context%} 

dns update:
  file.managed:
    - name: /etc/resolv.conf
    - contents:
{%- set host = grains['nodename'] %}
{%- set site = host[4:7] %}

{%- if site == 'mmp' %}
      - nameserver 10.200.2.220
{%- elif site  == 'ros' %}
      - nameserver 10.250.2.220
{%- elif site  == 'art' %}
      - nameserver 10.240.2.220
{% else %}
      - nameserver 10.200.2.220
{%- endif %}
