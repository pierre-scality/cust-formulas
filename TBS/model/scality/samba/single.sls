{% from "scality/samba/samba.jinja" import samba with context%} 

/ring/fs/share1:
    file.directory:
    - user:   {{ samba.testuser }}
    - group:  {{ samba.testgroup }}
    - mode:   755

quota batch:
  cmd.run:
    - name: squotabatch -d $(cat {{ samba.sfusedconf }} | jq '.general.dev') -b $(cat {{ samba.sfusedconf }} | jq '.["ring_driver:0"].bstraplist'|sed "s/\ //g")  scan /ring/fs/ -o /tmp/quota.report

set quota:
  cmd.run:
    - name: squotabatch -d $(cat {{ samba.sfusedconf }} | jq '.general.dev') -b $(cat {{ samba.sfusedconf }} | jq '.["ring_driver:0"].bstraplist'|sed "s/\ //g")  setusage -f /tmp/quota.report
