d=$(cat /etc/sfused.conf | jq '.general.dev')
b=$(cat /etc/sfused.conf | jq '.["ring_driver:0"].bstraplist'|sed "s/\ //g")
squotabatch -d $d -b $b  scan /ring/fs/  -o /root/quota.report
squotactl -b $b -d $d  setlimits -v 0 0 864000 0 0 864000
squotactl -d $d -b $b reportvols
squotabatch -d $d -b $b  setusage -f /root/quota.report
