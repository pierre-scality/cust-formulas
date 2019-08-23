/etc/resolv.conf:
  file.managed:
    - contents:
      - search opp.vic.gov.au
      - nameserver 172.16.1.36
      - nameserver 172.16.1.37
