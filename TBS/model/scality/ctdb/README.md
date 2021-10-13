# ha1

Setup a ctdb clluster

## Configuration
Configuration is in ctdb.yaml file
clustername: ctdbcluster
  => ctdb cluster name
security: ads
  => Enable or disable winbind in ctdb
smbservices: ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd']
  => This line is to restart smb should not change
ctdbmember:
  => list member of the cluster (python list format)
ctdbvip:
  => list the vip (with iface python list format)
ctdbconf:
  => ctdb configuration file (can be on sysconf/default dir sernet link both files)

You need to fill up the file files/nodes with all clusters ip.
Following command may work for you.
salt -G roles:ROLE_CONN_CIFS pillar.get scality:data_ip --out=txt | awk -F ':' '{print $2}'  > nodes


## Usage
Copy the files to /srv/scality/salt/local/scality/ctdb
salt <server> state.sls scality.ctdb 
ssh this server and register in the AD (net ads join) 
you probably need to start winbindd and you can stop it after for next step.
salt <server> state.sls scality.ctdb

##  Possible improvement
change for fileid in smb file is not indepotent. Probably there is a better way to do.
Could merge samba states and ctdb 
Add NFS support 

## Original writter
PM
