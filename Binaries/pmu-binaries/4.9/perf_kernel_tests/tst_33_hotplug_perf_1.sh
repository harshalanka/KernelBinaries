#!/bin/sh

./perf_test.x -w hotplug --alt_list u1,d1,u1 -m 0 -C 1 -o tmp1.txt && ./perf_test.x -w hotplug --alt_list u1,d1,u1 -m 0 -C 2 -o tmp2.txt
echo "make sure that perf.txt has events staying up on cpu 0 and stopping/restarting on cpu1 and then stopping/restarting on cpu 2"
exit

exit
# below is sample output
# we should see hw event (cycles & instr) on both cpus at start, plus swevent cpu-clock & context-switchs.
# then at hotplug stop countin on cpu 1 but continue on cpu 0
# then start counting on cpu 1 after hot plug in.
     1.402397500 S0-C1           1           58675934      instructions
     1.402397500 S0-C1           1         100.146667      cpu-clock (msec)
     1.402397500 S0-C1           1                  7      context-switches
     1.502534322 S0-C0           1           15434047      cycles
     1.502534322 S0-C0           1           11324946      instructions
     1.502534322 S0-C0           1         100.142709      cpu-clock (msec)
     1.502534322 S0-C0           1                 18      context-switches
     1.502534322 S0-C1           1      <not counted>      cycles
     1.502534322 S0-C1           1      <not counted>      instructions
     1.502534322 S0-C1           1      <not counted>      cpu-clock
     1.502534322 S0-C1           1      <not counted>      context-switches
     1.602671822 S0-C0           1             278768      cycles
     1.602671822 S0-C0           1              99076      instructions
     1.602671822 S0-C0           1         100.137708      cpu-clock (msec)
     1.602671822 S0-C0           1                  0      context-switches
     1.602671822 S0-C1           1      <not counted>      cycles
     1.602671822 S0-C1           1      <not counted>      instructions
     1.602671822 S0-C1           1      <not counted>      cpu-clock
     1.602671822 S0-C1           1      <not counted>      context-switches
     1.702806354 S0-C0           1              49964      cycles
     1.702806354 S0-C0           1              15305      instructions
     1.702806354 S0-C0           1         100.134167      cpu-clock (msec)
     1.702806354 S0-C0           1                  0      context-switches

