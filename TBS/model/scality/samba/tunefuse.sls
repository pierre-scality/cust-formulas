{% from "scality/samba/samba.jinja" import samba with context%}
{% if samba.dlm8_interface != None %}
{% set iface = samba.dlm8_interface %}
{% set dlm8_net = salt.network.subnets(iface)[0] %}
{% else %} 
{% set dlm8_net = samba.dlm8_network %}
{% endif %}

tune cache:
  file.serialize:
    - name: {{ samba.sfusedconf }}
    - dataset:
        "general":
          acl: true
          group_check: true
          dir_update_log_size: 16384
          case_insensitive: true
        "ino_mode:2":
          update_log_max_size: 16384
{% if samba.sfusedquota == True %}
        "quota":
          "enable": true,
          "enforce_limits": true,
          "accuracy_step1_enable": true
{% endif %}
{%- if samba.dlm8 == true %}
        "dlm":
          "enable": 1,
          "rpc_address_selector": "{{ dlm8_net }}"
{% endif %}
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion

scality-sfused:
  service.running:
    - restart: True
    - watch:
      - file: {{ samba.sfusedconf }}
