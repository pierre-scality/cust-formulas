
tune cache:
  file.serialize:
    - name: /etc/sfused.conf
    - dataset:
        "general":
          dir_update_log_size: 16384
          case_insensitive: true
        "ino_mode:2":
          update_log_max_size: 16384
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion

scality-sfused:
  service.running:
    - restart: True
    - watch:
      - file: /etc/sfused.conf
