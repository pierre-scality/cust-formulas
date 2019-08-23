# geo setup
This formulas configure the full setup of samba/nfs/geosynced (cdmi) architecture.
It includes samba settings and all fuse connectors configuration.
Note that the volume must have been created before hand.

There is a single replication host per site which has role ROLE_GEO and will switch between src/dst

This formulas are only for installation.

## Profile 
It is stored in definition.yml
A file definition.yaml.sample is present in the repo.
The definition file is in ../local/ dir to let sync this folder without changing configuration
Copy the file (but never push it to repo)

```yaml
logpath: /var/log
volumes: ["Shares","Trim"]
nfsserver: 10.200.5.61

journalnfs:
  vopp1-node1: ["Trim","10.200.5.61"]
  vopp1-node2: ["Trim","10.200.5.61"]
  vopp1-node3: ["Trim","10.200.5.61"]
  vopp2-node1: ["Trim","10.200.5.67"]
  vopp2-node2: ["Trim","10.200.5.67"]
  vopp2-node3: ["Trim","10.200.5.67"]

journaldir: /journal
georole: source

# host : cdmi source : cdmi dest  : sfullsync dest (8381)
source:
  #vopp1-node3: ['10.200.3.148','10.200.2.230','10.200.5.67']
  vopp1-node3: ['vopp1-node1','vopp2-node1','vopp2-node3']
  vopp2-node3: ['vopp2-node1','vopp1-node1','vopp1-node3']

# host : cdmi source (VIP if availabe) : cdmi dest (itself or VIP) : sfullsync source (8380)
destination:
  vopp1-node3: ['vopp2-node1','vopp1-node1','vopp2-node3']
  vopp2-node3: ['vopp1-node1','vopp2-node1','vopp1-node3']

```
logpath: Where the logs are to be stored.
volumes : list of volume (sofs) existing to be replicated
  It must be as well a directory inside the nfs server for journal.
nfsserver : nfsserver for journal 
journalnfs: Is the nfs server directory to mount for journal (mount nfs:/directory /journal)
journaldir: Is the directory that will mount the journal
georole: can be source or destination and must have a section below source/destination giving the IP
destination/source: for each connector describes the source/target (in order) of the replication 

## Usage

* Edit the definition.yaml with your own settings 
* To configure all just before replication :
	 salt-run state.orch scality.settings.orch 
* When both sites are completed setup replication with :
	salt-run state.orch scality.settings.orch-geo

The volumes must be created before hand and have the same dev id.

## TODO 
logrotate for sfullsync logs
Could use 2 hosts for repli one for SRC only and ne for DST only ...
Change the interface ['ip_interfaces']['eth0]' geodst with a paramter from definition file
