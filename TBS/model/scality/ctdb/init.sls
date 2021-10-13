{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 
{%- from "scality/map.jinja" import scality with context %}
{%- from "scality/zookeeper/cluster.sls" import client_hosts with context %}

{% for serv in ctdb.disabled %}
disable {{ serv }}:
  service.dead:
    - enable: false
    - name : {{ serv }}
{% endfor %}

{% set rlock = "/etc/ctdb/ctdb_recovery_lock.yaml" %}

scality-ctdb-scripts:
  pkg.installed

{%- for p in ["passwd","shadow","group"] %}
Winbind in {{ p }}:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: ^{{ p }}:.*
    - repl: "{{ p }}: files winbind"
{%- endfor %}

/etc/ctdb/nodes:
  file.managed:
    - source: salt://scality/ctdb/files/nodes

/etc/ctdb/public_addresses:
  file.managed:
    - contents:
{%- for ip in ctdb.floatingip %}
      - {{ ip }}/{{ctdb.floatingmask}} {{ctdb.floatingif}}
{%- endfor %}

configure ctdb_recovery_lock.yaml:
  file.managed:
    - name: {{ rlock }}
    - contents: |
        zk_hosts: {{ client_hosts | join(',') }}
        cluster: {{ ctdb.zkclustername }}

/etc/samba/smb.conf.d/global_ctdb.conf:
  file.managed:
    - contents:
      - clustering = yes

/etc/samba/smb.conf.d/global_ad.conf:
  file.managed:
    - source: salt://scality/ctdb/files/global_ad.tmpl
    - template: jinja

/etc/samba/smb.conf.d/global_names.conf:
  file.managed:
    - contents:
      - netbios name = {{ ctdb.clustername }}

change log size:
  file.replace:
    - name: /etc/samba/smb.conf
    - pattern: max log size =.*
    - repl: max log size = 100000

{%- for i in ['groups','users'] %}
enable enum {{ i }}:
  file.replace:
    - name: /etc/samba/smb.conf
    - pattern: winbind enum {{ i }} = no
    - repl: winbind enum {{ i }} = yes
 {%- endfor %} 

sernet-samba-ctdbd:
  service.running:
    - enable: True
    - restart: True
    - watch:
      - file: {{ rlock }}
      - file: /etc/ctdb/nodes
      - file: /etc/ctdb/public_addresses
      - file: /etc/samba/smb.conf.d/global_ctdb.conf
      - file: /etc/samba/smb.conf.d/global_ad.conf
      - file: /etc/samba/smb.conf.d/global_names.conf
      - file: /etc/samba/smb.conf
