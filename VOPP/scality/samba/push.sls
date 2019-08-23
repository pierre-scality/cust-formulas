{% from "scality/samba/samba.jinja" import samba with context%}

/etc/samba/smb.conf:
  file.managed:
    - source: salt://scality/samba/smb.conf.tmpl
    - template: jinja


sernet-samba-smbd:
  service.running:
    - watch: 
      - file: /etc/samba/smb.conf 
