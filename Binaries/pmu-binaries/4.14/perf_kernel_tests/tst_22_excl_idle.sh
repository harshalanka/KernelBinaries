#!/bin/sh

# this test runs perf stat with cycles event with the exclude_idle attribute.
# then it runs perf_test.x with a test which alternates busy and cycle intervals.
# The test expects that perf will report 0 counts during the idle period and 
# nonzero cycle counts during the busy periods.
# The test can falsely report FAILED if something else is running on cpu 1 
# so that cpu 1 never goes idle.
./perf stat -a --cpu 1 -e cycles:I -I 10 --per-core --verbose -o perf.txt  ./perf_test.x -w sleep -C 1 -t 1 --duty_cycle 0.10 > tmp.txt
./gawk -f tst_22_excl_idle.awk perf.txt

