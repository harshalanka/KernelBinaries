#!/bin/sh

# this test does a simple test to see if exclude idle attribute is supported.
# It asks perf to create an event with attribute and then prints out the header 
# and looks for the string which indicates that perf 'took' the attribute.
./perf record -a --cpu 1 -e cycles:I -o perf.dat  ./perf_test.x -w sleep -C 1 -t 1 --duty_cycle 0.10 > tmp.txt
./perf script --header -i perf.dat > tmp1.txt
./gawk -f tst_21_excl_idle.awk tmp1.txt
#./perf record -a -e sched:sched_switch -o perf1.dat --cpu 1 ./perf  stat -a -e cycles:I,cycles -I 10 --cpu 1 -o perf2.dat  ./perf_test.x -w sleep -t 5 -c 1 -l 100000000


