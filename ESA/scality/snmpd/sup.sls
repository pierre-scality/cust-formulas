{% from "scality/snmpd/map.jinja" import snmpd with context %}

configsup:
  cmd.run:
    - name: sagentd-manageconf -c /etc/sagentd.yaml add sup type=sup ssl=1 port=2443 address={{ salt['pillar.get']('scality:supervisor_ip') }}  user=root password={{ salt['pillar.get']('scality:credentials:internal_password') }}

{% set test = salt['pillar.get']('snmpd:sinkenable') %}

{% if snmpd.trapsinkenable == True %}
/etc/snmp/snmptrapd.conf:
  file.append:
    - text: "authCommunity log,execute,net public"
    - unless: grep -q 'authCommunity log,execute,net public' /etc/snmp/snmptrapd.conf 

/etc/sysconfig/snmptrapd:
  file.replace:
    - pattern: '^OPTIONS.*'
    - repl: OPTIONS="-Lsd -Lf /var/log/snmptrap.log -p /var/run/snmptrapd.pid"
    - append_if_not_found : True
    - backup: True

snmptrapd:
  service.running:
    - enable: False
    - watch:
      - file: /etc/snmp/snmptrapd.conf
{% endif %}
