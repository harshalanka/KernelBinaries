
memtoggle()
{
echo $1 > /sys/devices/system/memory/memory14/state
echo $1 > /sys/devices/system/memory/memory15/state
}

count=0
while 
do
	count=$((count+1))
	memtoggle offline
	memtoggle online_movable
	if [ $count == 20 ]
	then
		cat /sys/kernel/mem-offline/perf_stats >> pasrstats.txt
		cat /proc/uptime >> pasrstats.txt
		count=0
	else
		echo "$count"
	fi
done