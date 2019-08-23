{% from "scality/geo/definition.jinja" import definition with context %}
/etc/scality:
  file.directory

{{ definition.journaldir }}:
  file.directory

scality-sfullsyncd-source:
  pkg.installed

uwsgi:
  service.dead:
    - enable: false

{% for srv,mountpoint in definition.journalnfs.items() %}
{% if srv == grains.get('id') %}
{% set share = mountpoint[0] %}
{% set nfsserver = mountpoint[1] %}
mount nfs {{srv}} {{share}}:
  mount.mounted:
    - name: {{ definition.journaldir }}
    - device: {{ nfsserver }}:/{{ share }}
    - fstype: nfs
    - mkmnt: True
    - persist: True


set fuse configuration:
  file.serialize:
    - name: /etc/dewpoint-sofs.js
    - dataset:
        transport:
          mountpoint: "/ring/fs"
        general:
          geosync: true
          geosync_prog: "/usr/bin/sfullsyncaccept"
          geosync_args: "/usr/bin/sfullsyncaccept --v3 --user scality -w {{ definition.journaldir }} $FILE"
          geosync_interval: 10
          geosync_run_cmd: true
          geosync_tmp_dir: "/var/tmp/geosync"
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion


scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/dewpoint-sofs.js

{% endif %}
{% endfor %}

{% for service in ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd'] %}
start samba {{ service }}:
  service.running:
    - name: {{ service }}
    - enable: true
    - watch:
      - file: /etc/dewpoint-sofs.js
{% endfor %}


/tmp/fullsynctemp:
  file.managed:
    - contents:
      - roles {{ definition.georole }} 

