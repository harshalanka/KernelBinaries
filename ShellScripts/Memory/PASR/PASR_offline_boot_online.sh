#!/system/bin/sh
# Import test suite definitions

PASR_NODES=/sys/devices/system/memory
testClients=()
cnt=0
cntsuc=0
cntfail=0
offline=0 

while getopts ":f" opt
   do
     case $opt in
        f ) offline=1;;
    esac
done

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


if [ "$offline" == "0" ]; then
	for j in "${testClients[@]}"; do
		block_state=`cat $j/state`
		echo "$block_state"
		if [ "$block_state" != "online" ]; then
			let cntfail="cntfail + 1"
		fi 
	done
else
	for j in "${testClients[@]}"; do
		block_state=`cat $j/state`
		if [ "$block_state" == "online" ]; then
			echo offline > $j/state
		fi 
		
		block_state=`cat $j/state`
		if [ "$block_state" != "offline" ]; then
			let cntfail="cntfail + 1"
		fi 
	done
fi

echo "Failed attempts = $cntfail"

if [ $cntfail -eq 0 ]; then
	echo "Pass"
else
	echo "Fail"
	exit 1
fi