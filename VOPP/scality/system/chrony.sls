/etc/chrony.conf:
  file.managed:
    - source: salt://scality/system/chrony.conf

chronyd:
  service.running:
    - watch:
      - file: /etc/chrony.conf
