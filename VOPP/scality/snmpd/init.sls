{% from "scality/snmpd/map.jinja" import snmpd with context %}

net-snmp:
  pkg.installed

{{ snmpd.main_config }}:
  file.managed:
   - source: salt://scality/snmpd/files/snmpd.conf.tmpl
   - template: jinja

{{ snmpd.default_opts_file }}:
  file.managed:
    - source: salt://scality/snmpd/files/{{ grains.os_family }}.tmpl
    - template: jinja

{{ snmpd.service }}:
  service.running:
    - enable: True
    - watch:
      - file: {{ snmpd.default_opts_file }}
      - file: {{ snmpd.main_config }}

net-snmp-utils:
  pkg.installed
