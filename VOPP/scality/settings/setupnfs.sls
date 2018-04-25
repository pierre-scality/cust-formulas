{% from "scality/settings/definition.jinja" import definition with context %}

set root squash:
  file.managed:
    - name: /etc/exports.conf
    - source:
      - salt://scality/settings/files/root.conf

scality-sfused:
  service.running:
    - watch:
      - file: /etc/exports.conf

{%- set hostname = grains['id'] %}
/mnt:
  mount.mounted:
   - fstype: nfs
   - device: {{ hostname }}:/ 

{% for journal in definition.volumes %}
/mnt/{{ journal }}:
  file.directory:
    - user: scality
    - group: scality
{% endfor %}

umount file system:
  mount.unmounted:
    - name: /mnt
