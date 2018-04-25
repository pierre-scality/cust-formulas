{% from "scality/settings/definition.jinja" import definition with context %}
/etc/scality:
  file.directory

scality-sfullsyncd-source:
  pkg.installed

{% for srv,mountpoint in definition.journal.items() %}
{% if srv == grains.get('id') %}
mount nfs {{srv}} {{mountpoint}}:
  mount.mounted:
    - name: {{ definition.journaldir }}
    - device: {{ definition.nfsserver }}:{{mountpoint}}
    - fstype: nfs
    - mkmnt: True
    - persist: True
{% endif %}
{% endfor %}



{% for srv,ips in definition.source.items() %}
{% if srv == grains.get('id') %}
{% set geosourceip = ips[0] %}
{% set geotargetip = ips[1] %}


/etc/scality/sfullsyncd-source.conf:
  file.serialize:
    - dataset:
        cdmi_source_url: "http://{{ geosourceip }}"
        cdmi_target_url: "http://{{ geotargetip }}"
        sfullsyncd_target_url: "http://{{ geotargetip }}:8381"
        log_level: "info"
        journal_dir: {{ definition.journaldir }}
        ship_interval_secs: 5
        retention_days: 5
    - formatter: json
    - merge_if_exists: True
    - backup: minion

set fuse configuration:
  file.serialize:
    - name: /etc/dewpoint-sofs.js
    - dataset:
        transport:
          mountpoint: "/ring/fs"
        general:
          geosync: true,
          geosync_prog: "/usr/bin/sfullsyncaccept"
          geosync_args: "/usr/bin/sfullsyncaccept --v3 --user scality -w {{ definition.journaldir }} $FILE"
          geosync_interval: 10
          geosync_run_cmd: true
          geosync_tmp_dir: "/var/tmp/geosync"
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion

remove entry sagentd:
  cmd.run:
    - name: scality-sagentd-config -c /etc/sagentd.yaml remove -n {{ srv }}-sfullsync01
    - onlyif: grep -q {{ srv }}-sfullsync01 /etc/sagentd.yaml

{% if salt['pkg.version']('scality-sfullsyncd-target') %}
cleanup scality-sfullsyncd-target:
  service.dead:
    - name: scality-sfullsyncd-target
    - enable: false
{% endif %}

rsyslog file:
  file.managed:
    - name: /etc/rsyslog.d/30-scality-sfullsyncd-source.conf
    - source: salt://scality/settings/30-scality-sfullsyncd-source.conf
    - template: jinja
  service.running:
    - name: rsyslog
    - watch: 
      - file: /etc/rsyslog.d/30-scality-sfullsyncd-source.conf

scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/dewpoint-sofs.js
      - file: /etc/scality/sfullsyncd-source.conf

uwsgi:
  service.running:
    - enable: true
    - watch:
      - file: /etc/scality/sfullsyncd-source.conf

scality-sagentd:
  service.running:
    - restart: true
    - watch:
      - cmd: remove entry sagentd

/tmp/fullsynctemp:
  file.managed:
    - contents:
      - roles {{ definition.georole }} 
      - source {{ geosourceip }}
      - dst {{ geotargetip }}

{% endif %}
{% endfor %}

