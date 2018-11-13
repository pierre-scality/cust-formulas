# snmpd

This formula has 2 purpose :

1 - Provide a working snmpd conf that will replace existing one 

2 - Configure snmp on sup and snmptrad to get the trap

## Configuration
This formulas are build from standard snmpd ones.

The init state is to be run on  all servers, it will copy a functionnal snmpd.conf file with trap sink set to supervisor (see map.jinja)

The sup state is to run after on sup only, it will prepare and start snmptrapd for testing.

No need to change pillar but the local map.jinja has been modified.

map.jinja file  has the 2 following entries added:
```yaml
        'trapsinkenable': False,
        'trapsink': salt['pillar.get']('scality:supervisor_ip')
```

If trapsinkenable is set to True, snmptrapd will be configured on the sup and started (service not started)

## Usage 
After copying the files to /srv/scality/salt/local/scality/snmpd:

Run salt '*' state.sls scality.snmpd 

Then on sup :
salt-call state.sls scality.snmpd.sup

##  Possible improvement

Cover only redhat 

Should separate sup and trapdconfig

## Original writter
Fork by PM
