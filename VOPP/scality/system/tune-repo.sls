/etc/yum.conf:
  file.append:
    - text:
      - proxy=http://proxy.opp.vic.gov.au:3128
      - proxy_username=srv_scality
      - proxy_password=0pp1ntern3t11

{% for file in ['scality-internal','scality-offline','scality-saltstack'] %}
/etc/yum.repos.d/{{ file }}.repo:
  file.append:
    - text:
      - proxy=_none_ 
{% endfor %}

/etc/yum.repos.d/CentOS-Base.repo:
  pkgrepo.managed:
    - enabled: true
