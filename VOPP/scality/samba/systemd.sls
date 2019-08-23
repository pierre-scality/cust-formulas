Override sfullsync for adding fd:
  file.managed:
    - name: /etc/systemd/system/scality-sfullsyncd-target.service
    - source: salt://scality/settings/files/scality-sfullsyncd-target.service
    - unless: grep -q LimitNOFILE= /usr/systemd/system/scality-sfullsyncd-target.service 

reload systemd:
  module.run:
    - name: service.systemctl_reload
    - watch: 
      - file: /etc/systemd/system/scality-sfullsyncd-target.service
