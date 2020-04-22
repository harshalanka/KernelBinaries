#!/bin/sh

# this test checks if we can allocate events with the exclude_idle attribute.
# DCVS needs this attribute to avoid waking sleeping cpus.
# for this test, perf_test.x allocates a cycles event with exclude_idle and then alternates
# busy periods with idle periods on cpu 1.
# The test expects that the perf api used to read the event will return 0 if the cpu is idle.
# This test can report a false 'fail' if cpu 1 is never idle (say something else is running
# on the cpu during the test).

for i in `seq 0 1 10`; do 
  echo "try $i"
  cat /proc/stat |grep cpu1 > tmp1.txt
  ./perf_test.x -w sleep -C 1 -y all_pids,no_group -e cycles:I -I 10 -t 1 --duty_cycle 0.10 > tmp.txt
  cat /proc/stat |grep cpu1 > tmp2.txt
  ./gawk -f tst_20_excl_idle.awk tmp.txt > tmp3.txt
  echo "/proc/stat |grep cpu1 output before and after test"
  cat tmp1.txt
  cat tmp2.txt
  grep FAILED tmp3.txt > /dev/null
  if [ $? -gt 0 ]; then
     break
  fi
done
cat tmp3.txt


