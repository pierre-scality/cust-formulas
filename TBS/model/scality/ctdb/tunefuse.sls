{% from "scality/ctdb/ctdb.jinja" import ctdb with context%}

tune cache:
  file.serialize:
    - name: {{ ctdb.sfusedconf }}
    - dataset:
        "general":
          acl: true
          group_check: true
          dir_update_log_size: 16384
          case_insensitive: true
        "ino_mode:2":
          update_log_max_size: 32768
{% if ctdb.sfusedquota == True %}
        "quota":
          "enable": true,
          "enforce_limits": true,
          "accuracy_step1_enable": true
{% endif %}
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion

scality-sfused:
  service.running:
    - restart: True
    - watch:
      - file: {{ ctdb.sfusedconf }}
