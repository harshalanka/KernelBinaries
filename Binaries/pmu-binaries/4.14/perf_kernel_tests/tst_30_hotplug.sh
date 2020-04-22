#!/bin/sh

# tests non-sampling perf events.
# events cycles (hw event) & cpu-clock (sw event) are started on cpu 1 and reported 
# every 0.1 seconds. 
# section 1 (the 1st u1 in '-a u1,d1,u1'): cpu 1 stays up for 1 second, 
#   then get hotplugged offline
# section 2: (the 'd1' in the -a option) test continues for 1 second with cpu 1 offline
#   then cpu 1 gets hotplugged online 
# section 3: (the 2nd u1 in the -a option): test continues for 1 second with cpu 1 online
# Expect to see nonzero cycles and cpu-clock counts for section 1
# Expect to see    zero cycles and cpu-clock counts for section 2 (while cpu is offline)
# Expect to see nonzero cycles and cpu-clock counts for section 3 (if hotplug code successfully re-enabled the events)
# Passing looks like:
# /tmp # ./gawk -f tst_hotplug.awk tmp.txt
# got Timestamp line
# got overtime lines= 70
# section u1: zeroes=  0, nonzeroes= 12, evt= cpu-clock
# section u1: zeroes=  0, nonzeroes= 12, evt= cycles
# section d1: zeroes= 11, nonzeroes=  0, evt= cpu-clock
# section d1: zeroes= 11, nonzeroes=  0, evt= cycles
# section u1: zeroes=  0, nonzeroes= 12, evt= cpu-clock
# section u1: zeroes=  0, nonzeroes= 12, evt= cycles
# PASSED

./perf_test.x -w hotplug --alt_list u1,d1,u1 -t 3 -m 0 -C 1 -e cycles,cpu-clock -I 100 > tmp.txt
./gawk -f tst_30_hotplug.awk tmp.txt
