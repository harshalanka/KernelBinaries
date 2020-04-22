#!/bin sh

# This test check that perf_event_paranoid exists and is the correct value (3).
# If the kernel is not built with CONFIG_PERF_EVENTS and CONFIG_HW_PERF_EVENTS then
# the file won't exist.
# There is a blacklisting CR (see below) which requires that all kernels have the 
# value of perf_event_paranoid=3. This allows only root to use perf.
# If you have values < 3 then perf_fuzzer can crash the sytem.

err=0
flnm=/proc/sys/kernel/perf_event_paranoid

if [ -f $flnm ]; then
	echo "$flnm exists so kernel was compiled with CONFIG_PERF_EVENTS and CONFIG_HW_PERF_EVENTS"
else
	echo "$flnm not found so kernel was not compiled with CONFIG_PERF_EVENTS and CONFIG_HW_PERF_EVENTS so perf is not supported"
	err=1
fi

ckval=`cat $flnm`
if [ $ckval == 3 ]; then
	echo "$flnm value is correctly $ckval (so only root can execute perf)"
else
	echo "$flnm value is incorrectly $ckval. Should be 3 which allows only root to execute perf."
	echo "See https://prism.qualcomm.com/CR/1053488"
    # ck if busybox/kdev env and if so, let it pass
    ck_busybox=`ls -l /bin | grep busybox |wc -l`
    if [ $ck_busybox == 0 ]; then
          err=1
    else
          echo "probably running in kdev so probably not an error"
    fi
fi

if [ $err == 0 ]; then
	echo PASSED
else
	echo FAILED
fi
