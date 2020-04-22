#!/system/bin/sh
# Import test suite definitions

PASR_NODES=/sys/devices/system/memory
testClients=()
cnt=0
cntsuc=0
cntfail=0

while getopts ":d:" opt
   do
     case $opt in
        d ) duration=$OPTARG;;
    esac
done

if [ -z $duration ]; then
    duration=300
elif [ -n $duration ]; then
    duration=$duration
fi

cd $PASR_NODES

for f in *
do
	filename=$f
	var=`cat $f/removable` > /dev/null 2>&1
	varzone=`cat $f/valid_zones` > /dev/null 2>&1
	if [[ $var == 1 && $varzone == *"Movable"* ]]; then
		let cnt="cnt + 1"
		testClients[$cnt]=$f
	fi
done

echo "No. of movable clients: $cnt \n"
echo ${testClients[@]}


offlineOnline(){

	i=$1
	echo "===== Turning region on/off for $i\n"
	state=`cat $PASR_NODES/$i/state`

	if [[ $state == "offline" ]]; then

		echo online_movable > $PASR_NODES/$i/state
		sleep 3
		st1=`cat $PASR_NODES/$i/state`

		if [[ $st1 != "online" ]]; then
			echo "********* Could not set to ONLINE ***** \n"
			let cntfail="cntfail + 1"
		fi

		echo offline > $PASR_NODES/$i/state
        sleep 3
		st1=`cat $PASR_NODES/$i/state`

		if [[ $st1 != "offline" ]]; then
			echo "********* Could not set to OFFLINE ***** \n"
			let cntfail="cntfail + 1"
		fi

	else
		echo offline > $PASR_NODES/$i/state
		sleep 3
		st1=`cat $PASR_NODES/$i/state`

		if [[ $st1 != "offline" ]]; then
			echo "********* Could not set to OFFLINE ***** \n"
			let cntfail="cntfail + 1"
		fi

		echo online_movable > $PASR_NODES/$i/state
        sleep 3
		st1=`cat $PASR_NODES/$i/state`

		if [[ $st1 != "online" ]]; then
			echo "********* Could not set to ONlINE ***** \n"
			let cntfail="cntfail + 1"
		fi
	fi
}

end=$((SECONDS+duration))

let cnt="$cnt - 1"

while [ $SECONDS -lt $end ]; do
	loc=$(($RANDOM%2))
	let loc="loc + 1"
	echo ${testClients[$loc]}
	sleep 10
	offlineOnline ${testClients[$loc]}
done

echo "Failed attempts = $cntfail"

if [ $? -eq 0 ]; then
	echo "Pass"
else
	echo "Fail"
	exit 1
fi