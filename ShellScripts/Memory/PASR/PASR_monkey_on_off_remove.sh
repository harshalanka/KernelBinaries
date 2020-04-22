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

runmonkey()
{
monkey -s 246 --throttle 200 --ignore-timeouts --ignore-crashes --ignore-security-exceptions --kill-process-after-error --pct-trackball 0 --pkg-blacklist-file /data/local/tmp/blacklist.txt 2500
sleep 180
}

runmonkey
memtoggle offline
memremove
runmonkey
memprobe
cat /sys/kernel/mem-offline/perf_stats >> pasrstats.txt
cat /proc/uptime >> pasrstats.txt