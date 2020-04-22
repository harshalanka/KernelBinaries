# enable busybox
chmod 777 /data/busybox/busybox;
/data/busybox/busybox --install;
echo 1 > /sys/module/msm_performance/parameters/core_ctl_register
killall -9 rt-app
rm *.log
rm tidnums.txt
# start rt-app
./rt-app taskBoost.json &
timeout 10 monkey -s 100 --throttle 100 --ignore-crashes --ignore-timeouts --ignore-security-exceptions 1000
