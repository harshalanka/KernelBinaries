# enable busybox
set -x
chmod 777 /data/busybox/busybox;
/data/busybox/busybox --install;
echo 1 > /sys/module/msm_performance/parameters/core_ctl_register
killall -9 rt-app
rm *.log
rm tidnums.txt
input keyevent 82
input keyevent 82
am force-stop com.vectorunit.redcmgeplaycn 

monkey -s 100 --throttle 500 -p com.vectorunit.redcmgeplaycn --ignore-crashes --ignore-timeouts --ignore-security-exceptions 500

am force-stop com.vectorunit.redcmgeplaycn 