configure host file:
  salt.state:
    - tgt: '*'
    - sls: scality.settings.hosts

configure samba:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
    - sls: scality.samba

create shared directories on server:
  salt.state:
    - tgt: 'roles:ROLE_CONN_NFS'
    - tgt_type: grain
    - sls: scality.settings.setupnfs

configure cdmi:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
    - sls: scality.settings.cdmi

