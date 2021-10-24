Setup a ctdb cluster

## Configuration
Configuration is in ctdb.yaml file.
This formulas are designed for a AD based ctdb cluster.

General parameters :
sfusedquota: True/False => If you want to setup quota when running the sfused tuning sls
sfusedconf: /etc/scality/sfused.conf => path to sfused.conf 
disabled: List of services to disable at ctdb installation time (ctdb manage the services see ctdbsvc below)
  ['scality-sfused','sernet-samba-smbd','sernet-samba-nmbd','sernet-samba-winbindd']
restartctdb: True|False => Do we restart ctdb after modifying sfused configuration
ctdbtype: Define the service that ctdb shall manage and should match an entry in the ctdbsvc list
ctdbsvc: List of service to enable depending on ctdbtype value. It follows the documentation (2021/10/12)

Environement paramaters.
You need to define 2 grains :
scal_share -> to group a cluster that will share the same data
scal_dc -> Datacenter the server is in. It will be used to define the floating IP

Cluster parameters:
* shares : define for each share group the shares to be created, each entry is :
'sharename' : ['ring directory','permission to set in the valid user',['user','group']]
The ['user','group'] are used if you run the formula to create the ringfs directory and will be set as owner of the root dir

* vip : Define the VIP to asssign for a group of share depending on the datacenter 
vip:'share':'DC'
Each entry is a list with 3 entries (to file the file public_addresses)
[[ip1,ip2,...],netmask,"ifname"]

* nodes 
Sorted by share list of host belonging to this share group.
nodes:'share' ['ip1,ip2,...]

* cluster
Sorted by share list define the cluster name, realm and workgroup 
cluster:'share':['cluster name','realm (domainname)','work group (usually the first part of the fqdn']


such command can help to get the IP list
salt -G roles:ROLE_CONN_CIFS pillar.get scality:data_ip --out=txt | awk -F ':' '{print $2}' | sed -z 's/\n/,/g'
or 
salt -G roles:ROLE_CONN_CIFS network.ip_addrs nm-team-storage   --out=txt | awk -F "'" '{print $2}' | sed -z 's/\n/,/g'


## Usage
### preaprations 
Copy the files to /srv/scality/salt/local/scality/ctdb
Modify the ctdb.yaml with your parameters

### Install a first server in a share group
ssh to a first server on the cluster you want to install 
'''
salt-call state.sls scality.ctdb 
net ads join -U  # register the cluster in the AD. You'll need an AD admin account after -U and somebody for the passwd
net ads testjoin # Verify the registration
salt-call state.sls scality.ctdb.events  # Register the services events, it will restart ctdb
getent group # you should be able to list the AD after some time.
'''
You can ask customer to check AD registration. 
Then you can roll out the cluster configuration on all servers. 
You can actually use all the servers (including the just installed one) as it should be indepotent.
'''
salt -G scal_share <your share> scality.ctdb 
salt -G scal_share <your share> scality.ctdb.events
salt -G scal_share <your share> scality.ctdb.shares
'''

The last formula create the shares.
Repeast those steps for each share group.
You should be able to run in parallel. 
You can register a server per share group and then run the formula on all hosts belonging to a ctdb cluster.

##  Possible improvement
change for fileid in smb file is not indepotent. Probably there is a better way to do.
Could merge samba states and ctdb 
Add NFS support 

## Original writter
PM
