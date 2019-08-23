# ha1

This formula set up sagentd to use ha1

## Configuration
A single parameter to set which is the ip address ZK is running on in  ha1.yaml file
```yaml
        'interface': bond0
```


## Usage 
Copy the files to /srv/scality/salt/local/scality/ha1
Copy the ha1.yaml.sample to ha1.yaml and tune the interface name

Run salt '*' state.sls scality.ha1 

##  Possible improvement

sfused needs peer_tracking_enable to 1.
It is default but could for this value to on (JIC)

## Original writter
PM
