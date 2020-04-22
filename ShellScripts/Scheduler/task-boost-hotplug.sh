#!/bin/bash
chmod 777 /data/busybox/busybox;
/data/busybox/busybox --install;
echo 1 > /sys/module/msm_performance/parameters/core_ctl_register
killall -9 rt-app
rm *.log
rm tidnums.txt
mode=2
boostTime=30000
cpus=( "$@" )
echo "${cpus[@]}"
for i in "${cpus[@]}"
do 
	echo "offline cpu$i"
	echo 0 > /sys/devices/system/cpu/cpu$i/online
done
# start rt-app
./rt-app taskBoost.json &

# wait for rt-app to start all threads
sleep 1

temp2="$(top -b -H -n 1 -O tid | grep taskBoost | /data/busybox/busybox awk '{print $3}')"
echo "$temp2" > /data/local/tmp/tidnums.txt

# read each item in file and make sure its 0
while read p
do
	echo $mode > /proc/$p/sched_boost
	echo $boostTime > /proc/$p/sched_boost_period_ms
done < /data/local/tmp/tidnums.txt


# Change sched_group_id for all 40 threads to 10
while read p 
do
	echo 10 > /proc/$p/sched_group_id
done < /data/local/tmp/tidnums.txt

for i in "${cpus[@]}"
do 
	echo "online cpu$i"
	echo 1 > /sys/devices/system/cpu/cpu$i/online
done

# read each item in file and make sure its 10
while read p
do
	if [ $(cat /proc/$p/sched_group_id) == 10 ]
	then
		echo "thread $p group id is $(cat /proc/$p/sched_group_id)"
	else
		echo "thread $p group id is $(cat /proc/$p/sched_group_id)"
		echo "test failed"
	fi
done < /data/local/tmp/tidnums.txt

echo "all threads were put in sched group 10. Check if they are now running at big cluster. if they are, test is pass"
sleep 10