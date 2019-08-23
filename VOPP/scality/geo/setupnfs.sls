{% from "scality/geo/definition.jinja" import definition with context %}

set root squash:
  file.managed:
    - name: /etc/exports.conf
    - source:
      - salt://scality/geo/files/root.conf

scality-sfused:
  service.running:
    - watch:
      - file: /etc/exports.conf

{%- for srv,args in definition.journalnfs.items() %}
{%- set share = args[0] %}
{%- set nfsserver = args[1] %}
{% set a = loop.index %}
/tmp/a {{ srv }} {{ a }}:
  file.append:
    - name: /tmp/a
    - text: {{ srv }},{{ share  }},{{ nfsserver }}
{%- if srv == grains['id'] %}
{%- set vol = args[0] %}
{%- set ip = args[1] %}

/mnt:
  mount.mounted:
   - fstype: nfs
   - device: {{ srv }}:/ 
   - persist: False 

/mnt/{{ vol }}:
  file.directory:
    - user: scality
    - group: scality

witness file:
  file.managed:
    - name : /mnt/{{ vol }}/{{ vol }}
    - contents: Journal volume for {{ vol }}

umount file system:
  mount.unmounted:
    - name: /mnt

create exportfs conf:
  file.append:
    - name: /etc/exports.conf
    - text: /{{ vol}}\t*(rw)

restart fuse:
  service.running:
    - name: scality-sfused
    - watch:
      - file: /etc/exports.conf

create mountpoint:
  file.directory:
    - name: {{ definition.journaldir }}

{% endif %}
{% endfor %}
