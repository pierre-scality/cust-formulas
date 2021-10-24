{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 
{%- from "scality/zookeeper/cluster.sls" import client_hosts with context %}

{%- set myshare = grains['scal_share'] %}
{%- set mydc = grains['scal_dc'] %}

sernet-samba-winbind:
  pkg.installed


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
    - contents:
{%- for share,ips in ctdb.nodes.items() %}
{%- if share == myshare %}
{%- for ip in ips %}
      - {{ ip }}
{%- endfor %}
{%- endif %}
{%- endfor %}

/etc/ctdb/public_addresses:
  file.managed:
    - contents:
{%- for share,dclist in ctdb.vip.items() %}
{%- if share == myshare %}
{%- for dc,vip in dclist.items() %}
{%- if mydc == dc %}
{%- for this in vip[0] %}
      - {{this}}/{{vip[1]}} {{vip[2]}}
{%- endfor %}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endfor %}

/etc/samba/smb.conf.d/global_ctdb.conf:
  file.managed:
    - contents:
      - clustering = yes

{%- for share,params in ctdb.cluster.items() %}
{%- if share == myshare %}
{%- set mycluster = params[0] %}
{%- set myrealm = params[1] %}
{%- set myworkgroup = params[2] %}
/etc/samba/smb.conf.d/global_ad.conf:
  file.managed:
    - contents: 
      - security = ads
      - realm = {{ myrealm }}
      - 'idmap config {{ myworkgroup }} : backend = rid'
      - 'idmap config {{ myworkgroup }} : range =  2600000-3999999'

/etc/samba/smb.conf.d/global_names.conf:
  file.managed:
    - contents:
      - netbios name = {{ mycluster }}
      - server string = Samba Server Version %v
      - workgroup = {{ myworkgroup }}

configure ctdb_recovery_lock.yaml:
  file.managed:
    - name: {{ rlock }}
    - contents: |
        zk_hosts: {{ client_hosts | join(',') }}
        cluster: {{ mycluster }}
{%- endif %}
{%- endfor %}


change log size:
  file.replace:
    - name: /etc/samba/smb.conf
    - pattern: max log size =.*
    - repl: max log size = 100000

set vfs:
  file.replace:
    - name: /etc/samba/smb.conf
    - pattern: vfs.*
    - repl: vfs objects = ring catia fruit streams_xattr aio_pthread acl_xattr
    

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
