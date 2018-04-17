# geo setup
This formulas configure the full setup of samba/nfs/geosynced (cdmi) architecture.
It includes samba settings and all fuse connectors configuration.
Note that the volume must have been created before hand.



## Profile 
It is stored in definition.yml
A file definition.yaml.sample is present in the repo.
Copy the file (but never push it to repo)

```yaml
volumes: ["Shares","Trim"]
nfsserver: 10.100.1.118
journal: 
  vopp1-node1: /Trim
  vopp1-node2: /Shares
journaldir: /journal
georole: source
geoparam: 
  vopp1-node1: ['10.100.2.91','10.100.2.208']
```

volumes : list of volume (sofs) existing to be replicated
It must be as well a directory inside the nfs server for journal 
nfsserver : nfsserver for journal 
journal: Is the nfs server directory to mount for journal (mount nfs:/directory /journal)
journaldir: Is the directory that will mount the journal
geoparam: describes the source/target (in order) of the replication 

## Usage

* Edit the definition.yaml with your own settings 
* To configure all just before replication :
	 salt-run state.orch scality.settings.orch 
* When both sites are completed setup replication with :
	salt-run state.orch scality.settings.orch-geo

The volumes must be created before hand and have the same dev id.
