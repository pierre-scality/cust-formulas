{% from "scality/geo/definition.jinja" import definition with context %}
/etc/scality:
  file.directory

/{{ definition.journaldir }}:
  file.directory

scality-sfullsyncd-source:
  pkg.installed

{%- for srv,args in definition.journalnfs.items() %}
{%- if srv == grains['id'] %}
{%- set vol = args[0] %}
{%- set ip = args[1] %}
{{ definition.journaldir }}:
  mount.mounted:
    - fstype: nfs
    - device: {{ ip }}:/{{ vol }}
    - persist: True
{% endif %}
{% endfor %}


{% for srv,ips in definition.source.items() %}
{% if srv == grains.get('id') %}
{% set cdmisrc = ips[0] %}
{% set cdmidst = ips[1] %}
{% set fulldest = ips[2] %}
/etc/scality/sfullsyncd-source.conf:
  file.serialize:
    - dataset:
        cdmi_source_url: "http://{{ cdmisrc }}"
        cdmi_target_url: "http://{{ cdmidst }}"
        sfullsyncd_target_url: "http://{{ fulldest }}:8381"
        log_level: "info"
        journal_dir: {{ definition.journaldir }}
        ship_interval_secs: 5
        retention_days: 5
    - formatter: json
    - merge_if_exists: True
    - backup: minion

rsyslog file:
  file.managed:
    - name: /etc/rsyslog.d/30-scality-sfullsyncd-source.conf
    - source: salt://scality/geo/files/30-scality-sfullsyncd-source.conf
    - template: jinja
  service.running:
    - name: rsyslog
    - watch: 
      - file: /etc/rsyslog.d/30-scality-sfullsyncd-source.conf

uwsgi:
  service.running:
    - enable: true
    - watch:
      - file: /etc/scality/sfullsyncd-source.conf

{% if salt['pkg.version']('scality-sfullsyncd-target') %}
cleanup scality-sfullsyncd-target:
  service.dead:
    - name: scality-sfullsyncd-target
    - enable: false
{% endif %}

remove fullsyncd-target sagentd entry:
  cmd.run:
    - name: scality-sagentd-config -c /etc/sagentd.yaml remove -n {{ srv }}-sfullsync01
    - onlyif: grep -q {{ srv }}-sfullsync01 /etc/sagentd.yaml

scality-sagentd:
  service.running:
    - restart: true
    - watch:
      - cmd: remove fullsyncd-target sagentd entry

/tmp/fullsynctemp:
  file.managed:
    - contents:
      - roles {{ definition.georole }} 

{% endif %}
{% endfor %}
