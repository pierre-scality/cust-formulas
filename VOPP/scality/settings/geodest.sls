{% from "scality/settings/definition.jinja" import definition with context %}
/etc/scality:
  file.directory

/var/journal:
  file.directory:
    - user: scality
    - group: scality

scality-sfullsyncd-target:
  pkg.installed


{% for srv,ips in definition.geoparam.items() %}
{% if srv == grains.get('id') %}
{% set geosourceip = ips[0] %}
{% set geotargetip = ips[1] %}

/etc/scality/sfullsyncd-target.conf:
  file.serialize:
    - dataset:
       port: 8381
       log_level: "info"
       workdir: "/var/journal"
       cdmi_source_url: "http://{{ geosourceip }}"
       cdmi_target_url: "http://{{ geotargetip }}"
       enterprise_number: 37489
       sfullsyncd_source_url: "http://{{ geosourceip }}:8380"
    - formatter: json
    - merge_if_exists: True
    - backup: minion

add entry sagentd:
  cmd.run:
    - name: scality-sagentd-config -c /etc/sagentd.yaml add -n {{ srv }}-sfullsync01 -t sfullsyncd-target -H {{ geosourceip }} -p 8381

scality-sagentd:
  service.running:
    - restart: true
    - watch:
      - cmd: add entry sagentd

/tmp/a:
  file.managed:
    - contents:
      - {{ geosourceip }}
      - {{ geotargetip }}

{% endif %}
{% endfor %}

scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/scality/sfullsyncd-target.conf

enable scality-sfullsyncd-target:
  service.running:
    - name: scality-sfullsyncd-target
    - enable: true
