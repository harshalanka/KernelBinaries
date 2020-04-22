adb root
adb wait-for-device
adb remount
adb shell "echo 0 > /sys/kernel/debug/tracing/tracing_on"
adb shell "echo > /sys/kernel/debug/tracing/set_event"
adb shell "echo > /sys/kernel/debug/tracing/trace"
REM For Systrace
adb shell "echo power:sugov_hispeed_jmp >> /sys/kernel/debug/tracing/set_event"
adb shell "echo power:sugov_freq_update >> /sys/kernel/debug/tracing/set_event"
adb shell "echo sched:* >> /d/tracing/set_event"
adb shell "echo cpufreq_interactive:* >> /d/tracing/set_event"
adb shell "echo msm_low_power:* >> /d/tracing/set_event"
adb shell "echo thermal:* >> /d/tracing/set_event"
adb shell "echo irq:* >> /d/tracing/set_event"
adb shell "echo ipi:* >> /d/tracing/set_event"
adb shell "echo power:cpu_idle >> /d/tracing/set_event"
adb shell "echo power:clock_enable >> /d/tracing/set_event"
adb shell "echo power:clock_disable >> /d/tracing/set_event"
adb shell "echo power:clock_set_rate >> /d/tracing/set_event"
adb shell "echo power:cpu_frequency >> /d/tracing/set_event"
adb shell "echo power:core_ctl_eval_need >> /d/tracing/set_event"
adb shell "echo power:bw_hwmon_meas >> /d/tracing/set_event"
adb shell "echo power:bw_hwmon_update >> /d/tracing/set_event"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/sync/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/workqueue/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/options/print-tgid"
adb shell "echo 1 > /d/tracing/events/mdss/enable"
adb shell "echo 1 > /d/tracing/events/mdss/tracing_mark_write/enable"
adb shell cat /sys/kernel/debug/tracing/set_event
adb shell "echo 50000 > /sys/kernel/debug/tracing/buffer_size_kb"
adb shell "echo 1 > /sys/kernel/debug/tracing/tracing_on"
REM Run test on another cmd and wait for it to finish, then press any key
pause
adb shell "echo 0 > /sys/kernel/debug/tracing/tracing_on"
adb pull /sys/kernel/debug/tracing/trace trace.txt