{% from "scality/settings/definition.jinja" import definition with context %}
{% for volume in definition.volumes %}
{% for servers in definition.journal.{{ volume }}%}
mount journal {{ volume }}:
  salt.state:
    - tgt: {{ servers }}
    - sls: scality.settings.journal_{{ volume }}
