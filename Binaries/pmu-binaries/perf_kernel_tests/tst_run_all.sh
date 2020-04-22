#!/bin/sh

# usage: sh tst_run_all.sh [stop [iterations]]
# if you add the stop arg then if an err if found the script stops
# if you add the iterations arg then the script list is run iterations times
# the args are positional.
# So if you don't want to 'stop' but you do want 'iterations', then use 'cont' for arg 1.
# the script just checks arg1 == 'stop'

lst="tst_00_get_32bit_or_64bit_perf_binary tst_01_perf_pmu_loaded tst_02_perf_event_paranoid tst_10_allow_multiple_cycle_events tst_20_excl_idle tst_21_excl_idle tst_22_excl_idle tst_30_hotplug tst_31_hotplug_perf tst_32_hotplug_perf tst_33_hotplug_perf"

trap ctrl_c INT
got_quit=0

ctrl_c() {
    echo "** Trapped CTRL-C"
    got_quit=1
}

iters=0
if [ "$2" != "" ]; then
  iters=$2
fi

for j in `seq 0 $iters`; do
echo "======== iter $j ============="
for i in $lst; do
  echo ""
  echo "Start $i.sh"
  sh $i.sh | tee $i.out
  grep FAILED $i.out
  if [ $? == 0 ]; then
     echo "script $i.sh FAILED"
     if [ "$1" == "stop" ]; then
        exit
     fi
   fi
   if [ $got_quit == 1 ]; then
      exit
   fi
done
done

