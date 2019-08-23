configure host file:
  salt.state:
    - tgt: '*'
    - sls: scality.geo.hosts

configure samba:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
    - sls: scality.samba

create shared directories on server:
  salt.state:
    - tgt: 'roles:ROLE_CONN_NFS'
    - tgt_type: grain
    - sls: scality.geo.setupnfs

configure cdmi:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
    - sls: scality.geo.cdmi

