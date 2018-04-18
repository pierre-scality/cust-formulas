{% from "scality/settings/definition.jinja" import definition with context %}

/etc/scality:
  file.directory

{% for srv,ips in definition.geoparam.items() %}
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

remove entry sagentd:
  cmd.run:
    - name: scality-sagentd-config -c /etc/sagentd.yaml remove -n {{ srv }}-sfullsync01

scality-sagentd:
  service.running:
    - restart: true
    - watch:
      - cmd: remove entry sagentd


/tmp/fullsynctemp:
  file.managed:
    - contents:
      - source {{ geosourceip }}
      - dst {{ geotargetip }}

{% endif %}
{% endfor %}

scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/scality/sfullsyncd-source.conf

uwsgi:
  service.running:
    - enable: true
    - watch:
      - file: /etc/scality/sfullsyncd-source.conf

