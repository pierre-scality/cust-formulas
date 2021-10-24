{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 


/tmp/a:
  file.managed:
    - contents: |
{%- for sharegrp,shares in ctdb.shares.items() %}
{%- for share,args in shares.items() %}
{%- set path = args[0] %}
{%- set user = args[2][0] %}
{%- set group = args[2][1] %}
      {{ user }}
      {{ group }}

create dir {{ path }}:
  file.directory:
    - makedirs: True
    - name: {{ path }}
    - user: {{ user }}
    - group: {{ group }}


{%- endfor %}
{%- endfor %}

