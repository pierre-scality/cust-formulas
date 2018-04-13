{% from "scality/settings/definition.jinja" import definition with context %}
/etc/exports.conf:
  file.managed:
    - contents:
{% for journal in definition.volumes %}
      - /{{ journal }}     *(rw,no_root_squash)
{% endfor %}
      - /     {{ definition.nfsserver }}(rw,no_root_squash)
scality-sfused:
  service.running:
    - watch:
      - file: /etc/exports.conf

