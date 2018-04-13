{% from "scality/settings/definition.jinja" import definition with context %}
{% set a = definition.journal %}
{% for srv,mountpoint in definition.journal.items() %}
{% if srv == grains.get('id') %}
test file {{ srv }} {{ mountpoint }}:
  file.managed:
    - name: /tmp/a
    - contents:
      - {{ a }} 
      - {{ srv }} 
      - {{ mountpoint }}
mount nfs {{srv}} {{mountpoint}}:
  mount.mounted:
    - name: /journal
    - device: {{ definition.nfsserver }}:{{mountpoint}}
    - fstype: nfs
    - mkmnt: True
    - persist: True
{% endif %}
{% endfor %}
