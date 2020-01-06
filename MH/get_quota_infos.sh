export d=$(cat /etc/sfused.conf | jq '.general.dev')
export b=$(cat /etc/sfused.conf | jq '.["ring_driver:0"].bstraplist'|sed "s/\ //g") 

# format type:devid:id:name:inode:quota

squotactl -b $b reportvols |awk '$1=="volume"{print "volume",$2,$2,"volume"$2,$4,$7}'

getquota(){
  dev=$1
  type=$2
  name=$3
  case $2 in 
    group ) 
  	#echo :: get quota for $name 
  	squotactl -b $b -d $d report -g ${name} |awk -v dev=${dev} -v gn="${name}" '$1=="group"{print "group",dev,$2,gn,$4,$7}'
	;;
    user ) 
  	#echo :: get quota for $name
  	squotactl -b $b -d $d report -u ${name} |awk -v dev=${dev} -v gn="${name}" '$1=="user"{print "user",dev,$2,gn,$4,$7}'
	;;
    * ) 
	echo "Invalid user/group $2 $3"
  esac
}

squotactl -b $b -d $d ls |awk '{printf "%s %s\n",$1,$3}' | sed '1d' | while read a
  do
    getquota $d ${a}
  done
