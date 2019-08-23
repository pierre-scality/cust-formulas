{% from "scality/samba/samba.jinja" import samba with context%} 

/etc/default/sernet-samba:
  file.replace:
    - pattern: SAMBA_START_MODE.*
    - repl: 'SAMBA_START_MODE="classic"'

{% for p in samba.processes %}
start samba {{ p }}:
  service.running:
    - name: {{ p }}
    - enable: True
{% endfor %}

create test user:
  user.present:
    - name: {{ samba.testuser }}
    - fullname: Scality SMB test user
    - shell: /bin/bash
    - home: /home/{{ samba.testuser }}
    - uid: 2000
    - gid: scality

create test user samba:
  cmd.run:
    - name: printf 'saltiscool\nsaltiscool' | pdbedit -a -u {{ samba.testuser }} 
    - unless: pdbedit -L|grep -w {{ samba.testuser }}

