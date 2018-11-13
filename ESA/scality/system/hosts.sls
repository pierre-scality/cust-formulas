
/etc/hosts:
  file.managed:
    - source: salt://scality/system/hosts.tmpl
    - template: jinja
