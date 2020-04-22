#!/bin/sh

chmod +x ./perf4.19
chmod +x ./filemonkey

# Randomly hotplug the CPUs
./filemonkey /sys/devices/system/cpu/cpu0/online r 50000 500000 0 1 &
./filemonkey /sys/devices/system/cpu/cpu1/online r 50000 500000 0 1 &
./filemonkey /sys/devices/system/cpu/cpu2/online r 50000 500000 0 1 &
./filemonkey /sys/devices/system/cpu/cpu3/online r 50000 500000 0 1 &
./filemonkey /sys/devices/system/cpu/cpu4/online r 50000 500000 0 1 &
./filemonkey /sys/devices/system/cpu/cpu5/online r 50000 500000 0 1 &
./filemonkey /sys/devices/system/cpu/cpu6/online r 50000 500000 0 1 &
./filemonkey /sys/devices/system/cpu/cpu7/online r 50000 500000 0 1 &

# The following stress test:
# 1. Creates and destroys multiple sampling and counting events
# 2. perf record creates the num of events > the ARM PMU hardware counters so that event multplexing can be excercised at the perf-core
# 3. perf record also generates many interrupts, and hence even that path is tested
while true; do ./perf4.19 record -e cycles,instructions,cycles,instructions,cycles,instructions,cycles,instructions -a -g -o /data/perf_raw -- sleep 5 ; done &
while true; do ./perf4.19 stat -e cycles,instructions sleep 2 ; done
