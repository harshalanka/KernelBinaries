# !/system/bin/sh
set -x
echo 'Hoplug CPU0' 
/data/local/tmp/filemonkey /sys/devices/system/cpu/cpu0/online r 5000 50000 0 1 &
echo 'Hoplug CPU4' 
/data/local/tmp/filemonkey /sys/devices/system/cpu/cpu4/online r 5000 50000 0 1 &
echo 'Hoplug CPU7' 
/data/local/tmp/filemonkey /sys/devices/system/cpu/cpu7/online r 5000 50000 0 1 &	


