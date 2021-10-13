
/etc/ntp.conf:
  file.managed:
    - source: salt://scality/samba/ntp.conf


ntpd:
  service.running:
    - watch: 
      - file: /etc/ntp.conf

