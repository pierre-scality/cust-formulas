{% from "scality/samba/samba.jinja" import samba with context%} 

/etc/krb5.conf:
  file.comment:
    - regex: ^includedir.*

scality-cifs:
  pkg.installed

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
    - pattern: ^SAMBA_START_MODE.*
    - repl: 'SAMBA_START_MODE="classic"'

cifs-utils:
  pkg.installed:
    - fromrepo: base

scality-nasdk-tools:
  pkg.installed

/etc/samba/smb.conf:
  file.managed:
    - source: salt://scality/samba/smb.conf.tmpl
    - template: jinja

scality-sfused:
  service.running:
    - enable: true
    - reload: true
    - watch:
      - file: /etc/samba/smb.conf

sernet-samba-smbd:
  service.running:
    - watch: 
      - file: /etc/samba/smb.conf 

{%- if samba.forcedns == true %}
/etc/resolv.conf:
  file.managed:
    - contents:
      - search {{ samba.realm }}
      - nameserver {{ samba.dnsserver }}
{% endif %}
