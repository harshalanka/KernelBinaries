#!/bin sh

# This test check that perf_event_paranoid exists and is the correct value (3).
# If the kernel is not built with CONFIG_PERF_EVENTS and CONFIG_HW_PERF_EVENTS then
# the file won't exist.
# There is a blacklisting CR (see below) which requires that all kernels have the 
# value of perf_event_paranoid=3. This allows only root to use perf.
# If you have values < 3 then perf_fuzzer can crash the sytem.

./perf stat -e cycles -o perf.txt sleep 1
lnes=`./gawk '/not counted/{print;}' perf.txt`
if [ $lnes > 0 ]; then
	echo "failed to create even 1 event, need at least 1 for tests to work"
	echo "FAILED"
	exit
fi

echo PASSED
