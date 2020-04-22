memtoggle()
{
echo $1 > /sys/devices/system/memory/memory14/state
echo $1 > /sys/devices/system/memory/memory15/state
cat /sys/devices/system/memory/memory*/state
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

runstress()
{
./stress-ng-64 --vm 1 --vm-bytes 5000M -t 60s
sleep 5
}



runstress
memtoggle offline
runstress
memremove
runstress
memprobe
cat /sys/kernel/mem-offline/perf_stats >> pasrstats.txt
cat /proc/uptime >> pasrstats.txt