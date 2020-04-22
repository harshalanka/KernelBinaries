adb wait-for-device
adb wait-for-device
adb root
adb wait-for-device
adb wait-for-device

adb push \\sundae\APT_Logs_PPTKGolden\Kernel\Test-binaries-compact\RT\rt-app /data/local/tmp/rt-app
adb shell chmod 777 /data/local/tmp/rt-app
adb push \\sundae\APT_Logs_PPTKGolden\Kernel\Test-binaries-compact\RT\real-load\audio.json /data/local/tmp/audio.json

REM # Clearing
adb shell "echo 0 > /sys/kernel/debug/tracing/tracing_on"
adb shell "echo > /sys/kernel/debug/tracing/set_event"
adb shell "echo > /sys/kernel/debug/tracing/trace"

REM # Enabling traces
REM # Test level
adb shell "echo sched:sched_switch >> /sys/kernel/debug/tracing/set_event"
adb shell "echo power:cpu_frequency >> /sys/kernel/debug/tracing/set_event"

REM # Debug Level
REM adb shell "echo sched:* >> /sys/kernel/debug/tracing/set_event"
REM adb shell "echo power:sugov_util_update >> /sys/kernel/debug/tracing/set_event"
adb shell cat /sys/kernel/debug/tracing/set_event

REM # Set Buffer
adb shell "echo 50000 > /sys/kernel/debug/tracing/buffer_size_kb"
adb shell cat /sys/kernel/debug/tracing/buffer_size_kb

REM # Start Tracing
adb shell "echo 1 > /sys/kernel/debug/tracing/tracing_on

REM # Execute
adb shell /data/local/tmp/rt-app /data/local/tmp/audio.json

REM # Stop Tracing
adb shell "echo 0 > /sys/kernel/debug/tracing/tracing_on

REM # Pull Traces
adb pull /sys/kernel/debug/tracing/trace fake-audio-trace.txt