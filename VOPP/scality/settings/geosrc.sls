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
        journal_dir: {{ definition.journal }}
        ship_interval_secs: 5
        retention_days: 5
    - formatter: json
    - merge_if_exists: True
    - backup: minion

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
      - file: /etc/scality/sfullsyncd-source.conf

