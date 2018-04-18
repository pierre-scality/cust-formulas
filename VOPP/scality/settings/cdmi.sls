{% from "scality/settings/definition.jinja" import definition with context %}

/ring:
  file.directory
  
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

scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/dewpoint.js
