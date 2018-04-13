{% from "scality/settings/definition.jinja" import definition with context %}
{% for srv,mountpoint in definition.journal.items() %}
{% if srv == grains.get('id') %}
mount nfs {{srv}} {{mountpoint}}:
  mount.mounted:
    - name: {{ definition.journaldir }}
    - device: {{ definition.nfsserver }}:{{mountpoint}}
    - fstype: nfs
    - mkmnt: True
    - persist: True
{% endif %}
{% endfor %}
