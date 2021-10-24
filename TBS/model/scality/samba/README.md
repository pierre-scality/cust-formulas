# Samba setting

Configure samba connector
Support 2 modes security user and ad
Support as well fuse configuration (including dlm8)


## Usage 
Copy samba directory on /srv/scality/salt/local/scality/samba 
Configure samba setting in samba.yaml file 
Run 
```
  salt <target> state.sls scality.samba
  salt <target> state.sls scality.samba.tunesfuse
  salt <target> state.sls scality.samba.restartsmb
```

tunefuse formula restart sfused on changed on sfused.conf

You can later on manage samba conf by modifying template and run 
```
  salt <target> state.sls scality.samba.push 
```

It will restart smbd (only) and sfused on change to smb.conf
 
## Configuration
Before running salt state one needs to configure the following settings in samba.yaml file
You also have to check the samba template file smb.conf.tmpl (which should be ok like that most of case)

ad: true
  => true or false. it will configure samba in security user or ads
realm: <Customer realm> 
  => Usually dns domain usually in capital letters like SCALJP.ORG
addomain: <ad domain>  
  => usually first word of the realm like SCALJP
dnsserver: <DNS server IP>
  => DNS server ip, no sure formula handle multiple IP
forcedns: false 
  => true or false, true will rewrite resolv.conf and prevent dhcp to overwrite it
  => Should be false on customer env and true on test lab where you own AD like scality cloud for example

testuser: samba
testgroup: scality
  => Formula will create a local test user, pu what you like there.
  => passwd hardcoded in the init.sls formula (saltiscool)

dlm8: true
dlm8_network: 10.200.0.0/16
sfusedconf: /etc/scality/sfused.conf
sfusedquota: true
  => Those 3 lines are for sfused configuration 
  => formula is tunesfused which will modify sfused.conf (sfusedconf file above)
  => if you use dlm8 you need a param in sfused.conf, if this is the case set dlm to true otherwise false

The following 2 lines should not be changed 
processes: ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd']
nssmode: "files winbind"

# the single.sls formula
It is use to run command against a single server.
For now it creates the shared dir and setup quotas.
To be adapted with what's you need.

##  Possible improvement

## Original writter
PM
