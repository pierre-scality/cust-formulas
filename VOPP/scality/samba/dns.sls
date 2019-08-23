{% from "scality/samba/samba.jinja" import samba with context%} 

dns update:
  file.managed:
    - name: /etc/resolv.conf
    - contents:
      - search {{ samba.search }}
{%- for srv in samba.nameserver %}
      - nameserver {{ srv }}
{%- endfor %}

