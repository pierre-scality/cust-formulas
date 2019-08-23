
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

set fuse configuration:
  file.serialize:
    - name: /etc/dewpoint-sofs.js
    - dataset:
        general:
          acl: 1,
          group_check: 1
          dir_update_log_size: 16384
          case_insensitive: true
        "ino_mode:2":
          update_log_max_size: 16384
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion


scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/dewpoint.js
      - file: /etc/dewpoint-sofs.js
    - restart: True
