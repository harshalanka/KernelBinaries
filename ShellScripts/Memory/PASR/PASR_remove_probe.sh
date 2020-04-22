
memtoggle()
{
echo $1 > /sys/devices/system/memory/memory14/state
echo $1 > /sys/devices/system/memory/memory15/state
}

memremove()
{
echo 0x1E0000000 > /sys/devices/system/memory/remove
echo 0x1C0000000 > /sys/devices/system/memory/remove
}

memprobe()
{
echo 0x1E0000000 > /sys/devices/system/memory/probe
echo 0x1C0000000 > /sys/devices/system/memory/probe
}

count=0
count2=0
while 
do
	count=$((count+1))
	count2=$((count2+1))
	memtoggle offline
	sleep 3
	memremove
	sleep 3
	memprobe
	sleep 3
	if [ $count == 20 ]
	then
		cat /sys/kernel/mem-offline/perf_stats >> pasrstats.txt
		cat /proc/uptime >> pasrstats.txt
		count=0
	else
		echo "$count2"
	fi
done