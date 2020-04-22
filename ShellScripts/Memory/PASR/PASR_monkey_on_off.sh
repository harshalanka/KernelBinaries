memtoggle()
{
echo $1 > /sys/devices/system/memory/memory12/state
echo $1 > /sys/devices/system/memory/memory13/state
echo $1 > /sys/devices/system/memory/memory14/state
echo $1 > /sys/devices/system/memory/memory15/state
cat /sys/devices/system/memory/memory*/state
}

monkey -s 246 --throttle 200 --ignore-timeouts --ignore-crashes --ignore-security-exceptions --kill-process-after-error --pct-trackball 0 --pkg-blacklist-file /data/local/tmp/blacklist.txt 2500
sleep 180
i=1; while [ $(($i)) -le 3 ]; do memtoggle offline; memtoggle online_movable; i=$(($i + 1)); echo $i; done
cat /sys/kernel/mem-offline/perf_stats >> pasrstats.txt
cat /proc/uptime >> pasrstats.txt