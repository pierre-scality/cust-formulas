{% from "scality/settings/definition.jinja" import definition with context %}

scality-sfullsyncd-source:
  pkg.installed

httpd:
  service.running:
    - watch:
      - file: /etc/httpd/conf/httpd.conf
  file.uncomment:
    - name: /etc/httpd/conf/httpd.conf
    - regex: ^Listen 80$

enable fuse mount:
  file.serialize:
    - name: /etc/dewpoint.js
    - dataset:
        sofs: 
          enable_fuse: true
    - formatter: json
    - create: False
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

scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/dewpoint.js
      - file: /etc/dewpoint-sofs.js

