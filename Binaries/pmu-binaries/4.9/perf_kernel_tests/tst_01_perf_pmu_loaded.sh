#!/bin/sh

# this test tries to determine if the cpu_pmu driver is loaded
# It is expected that the driver will put a message like below in the kernel log.
#[    6.203559] hw perfevents: enabled with armv8_pmuv3 PMU driver, 7 counters available
# dmesg uses a ring buffer so the cpu pmu msg will get overwritten eventually
# Other ways it go wrong: the driver might not print message, or you may have another driver which prints a pmu msg

dmesg | grep -i pmu
if [ $? == 0 ]; then
	echo "perf pmu seems to be loaded"
	echo "PASSED"
else
	dmesg | grep -i pmu
	echo "couldn't find pmu string in dmesg output"
	echo "Maybe the dmesg ring buffer has flushed the message?"
	echo "The 'pmu' string should appear early in the boot messages... if there are too many kernel msgs then the older messages are dropped "
	echo "Assuming that the msg hasn't scrolled out of the dmesg buffer then you need a cpu_pmu entry in .dtsi"
	echo "See https://review-android.quicinc.com/#/c/1890472/ for example"
	echo "FAILED"
fi
