#!/bin/sh

read -d '' lst << EOF
gawk perf.32 perf.64 perf_test.x
tst_00_get_32bit_or_64bit_perf_binary.sh
tst_01_perf_pmu_loaded.sh
tst_02_perf_event_paranoid.sh
tst_03_at_least_1_counter_avail.sh
tst_10_allow_multiple_cycle_events.sh
tst_20_excl_idle.awk
tst_20_excl_idle.sh
tst_21_excl_idle.awk
tst_21_excl_idle.sh
tst_22_excl_idle.awk
tst_22_excl_idle.sh
tst_30_hotplug.awk
tst_30_hotplug.sh
tst_31_hotplug_perf.awk
tst_31_hotplug_perf.sh
tst_32_hotplug_perf.awk
tst_32_hotplug_perf.sh
tst_33_hotplug_perf_1.sh
tst_33_hotplug_perf.sh
tst_run_all.sh
EOF
echo $lst
tar cvf perf_kernel_tests.tar $lst
gzip -f perf_kernel_tests.tar


