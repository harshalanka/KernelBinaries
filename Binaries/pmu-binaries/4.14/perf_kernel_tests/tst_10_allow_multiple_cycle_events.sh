#!/bin/sh

# This test checks if you can allocate more than 1 cycle counter.
# By default, arm pmu driver accepts the 1st cycle event request and,
# if the cycle counter is still in use, rejects any subsequent requests.

# this test requests 2 cycle events and then checks that we get 
# at least 10*2 + 2 header lines of output (where we run for 1 sec
# and print out event values each 100 ms... so 10 prints per event).

./perf stat -a --cpu 1 --per-core -I 100 -e cycles,cycles -o perf.out sleep 1

ROWS=`cat perf.out | wc -l`

if [ $ROWS -gt 22 ]; then
  echo PASSED
else
  echo "expected to see 2 cycles events per interval"
  echo "might need https://review-android.quicinc.com/#/c/1891075/" 
  echo FAILED
fi

