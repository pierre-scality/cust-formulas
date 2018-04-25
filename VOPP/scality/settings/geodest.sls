{% from "scality/settings/definition.jinja" import definition with context %}
/etc/scality:
  file.directory

/var/journal:
  file.directory:
    - user: scality
    - group: scality

scality-sfullsyncd-target:
  pkg.installed

umount journal:
  mount.unmounted:
    - name: {{ definition.journaldir }}
    - persist: True

/journal:
  file.absent

{% for srv,ips in definition.destination.items() %}
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
    - unless: grep -q {{ srv }}-sfullsync01 /etc/sagentd.yaml

scality-sagentd:
  service.running:
    - restart: true
    - watch:
      - cmd: add entry sagentd

wipe geosync entry:
  cmd.run:
    - name: sed -i  /geosync/d /etc/dewpoint-sofs.js
    - onlyif: grep -q geosync /etc/dewpoint-sofs.js


{% if salt['pkg.version']('scality-sfullsyncd-source')  %}
remove scality-sfullsyncd-source:
  service.dead:
    - name: uwsgi
    - enable: false
{% endif %}

scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/scality/sfullsyncd-target.conf
      - cmd: wipe geosync entry

rsyslog file:
  file.managed:
    - name: /etc/rsyslog.d/30-scality-sfullsyncd-target.conf
    - source: salt://scality/settings/files/30-scality-sfullsyncd-target.conf
    - template: jinja
  service.running:
    - name: rsyslog
    - restart: true
    - watch:
      - file: /etc/rsyslog.d/30-scality-sfullsyncd-target.conf

enable scality-sfullsyncd-target:
  service.running:
    - name: scality-sfullsyncd-target
    - enable: true
    - watch:
      - file: /etc/rsyslog.d/30-scality-sfullsyncd-target.conf
      - file: /etc/scality/sfullsyncd-target.conf

/tmp/a:
  file.managed:
    - contents:
      - role {{ definition.georole }}
      - source {{ geosourceip }}
      - dest {{ geotargetip }}

{% endif %}
{% endfor %}

