{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 


/tmp/createshares:
  file.managed:
    - contents:
{%- for sharegrp,shares in ctdb.shares.items() %}
{% for share,args in shares.items() %}
{%- set path = args[0] %}
      - mkdir -p {{ path }}
{%- set user = args[2][0] %}
{%- set group = args[2][1] %}
{%- if user != "" %}
      - chown {{ user }} {{ path }}
      - setfacl -m u:{{ user }}:rwx {{ path }}
{% endif %}
{%- if group != "" %}
      - chgrp {{ group }} {{ path }}
      - setfacl -m g:{{ group }}:rwx {{ path }}
{% endif %}
{%- endfor %}
{%- endfor %}

