{% from "scality/samba/samba.jinja" import samba with context%} 

/etc/krb5.conf:
  file.comment:
    - regex: ^includedir.*

/etc/hosts:
  host.only:
    - name: {{ grains['ip4_interfaces']['eth0'][0] }}
    - hostnames: {{ grains['host']  }} {{ grains['host']  }}.{{ samba.realm }}

{%- if samba.ad == true %}
{%- for p in ["passwd","shadow","group"] %}
Winbind in {{ p }}:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: ^{{ p }}:.*
    - repl: "{{ p }}: files winbind"

{%- endfor %}
{%- endif %}

/etc/default/sernet-samba:
  file.replace:
    - pattern: SAMBA_START_MODE.*
    - repl: 'SAMBA_START_MODE="classic"'

create group scality:
  group.present:
    - name: scality 
    - gid: 2000

create test user:
  user.present:
    - name: {{ samba.testuser }}
    - fullname: Scality SMB test user
    - shell: /bin/bash
    - home: /home/{{ samba.testuser }}
    - uid: 2000
    - gid: scality

cifs-utils:
  pkg.installed:
    - fromrepo: base

scality-nasdk-tools:
  pkg.installed

/etc/samba/smb.conf:
  file.managed:
    - source: salt://scality/samba/smb.conf.tmpl
    - template: jinja

{%- if samba.forcedns == true %}
/etc/resolv.conf:
  file.managed:
    - contents:
      - search {{ samba.realm }}
      - nameserver {{ samba.dnsserver }}

/etc/sysconfig/network-scripts/ifcfg-eth0:
  file.line:
    - mode: ensure
    - content: PEERDNS=no
    - after: BOOTPROTO
{% endif %}

create test user samba:
  cmd.run:
    - name: printf 'saltiscool\nsaltiscool' | pdbedit -a -u {{ samba.testuser }} 
    - unless: pdbedit -L|grep -w {{ samba.testuser }}
