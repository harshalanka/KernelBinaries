#!/bin/sh

chmod +x *

# Count the cycles events on cpu-1 for every 200 ms
./perf4.19 stat -e cycles -I 200 -C 1 &

# Make the CPU-1 offline and online continuously
while true; do
	sleep 2
	echo 0 > /sys/devices/system/cpu/cpu1/online
	sleep 2
	echo 1 > /sys/devices/system/cpu/cpu1/online
done
