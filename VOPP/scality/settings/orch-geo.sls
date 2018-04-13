configure geo sync:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
    - sls: scality.settings.geosrc
