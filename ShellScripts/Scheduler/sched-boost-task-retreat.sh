# enable busybox
chmod 777 /data/busybox/busybox;
/data/busybox/busybox --install;
echo 1 > /sys/module/msm_performance/parameters/core_ctl_register
killall -9 rt-app
rm *.log
rm tidnums.txt


# start rt-app
./rt-app taskBoost.json &
sleep 2
#enabling sched boost
echo 1 > /proc/sys/kernel/sched_boost
# wait for rt-app to start all threads
sleep 2
# disabling sched_boost
echo 0 > /proc/sys/kernel/sched_boost
sleep 10