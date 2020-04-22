#!/bin/bash
# enable busybox
set -x
chmod 777 /data/busybox/busybox;
/data/busybox/busybox --install;
echo 1 > /sys/module/msm_performance/parameters/core_ctl_register
killall -9 rt-app
rm *.log
rm tidnums.txt
cpus=( "$@" )
./rt-app taskBoost.json &
sleep 6
firstCpuFmax=`cat /sys/devices/system/cpu/cpu${cpus[0]}/cpufreq/scaling_max_freq`
counter=0
for i in "${cpus[@]}"
do
	if [ $i -eq 0 ]
	then
		continue
	fi
	cpuAvailableFreq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies)
	cpuAvailableFreq=( $cpuAvailableFreq )
	for j in ${cpuAvailableFreq[*]}
	do
		if [ $j -lt $firstCpuFmax ]
		then
			if [ $counter -eq 0 ]
			then
				echo $j > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
				counter=$(($counter+1))
			fi
		fi
	done
	counter=0
	echo 0 > /sys/devices/system/cpu/cpu$i/online
	echo 1 > /sys/devices/system/cpu/cpu$i/online
done
sleep 1
counter=0
for i in "${cpus[@]}"
do
	if [ $i -eq 0 ]
	then
		continue
	fi
	cpuAvailableFreq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies)
	cpuAvailableFreq=( $cpuAvailableFreq )
	for j in ${cpuAvailableFreq[*]}
	do
		if [ $j -gt $firstCpuFmax ]
		then
			if [ $counter -eq 0 ]
			then
				echo $j > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
				counter=$(($counter+1))
			fi
		fi
	done
	counter=0
	echo 0 > /sys/devices/system/cpu/cpu$i/online
	echo 1 > /sys/devices/system/cpu/cpu$i/online
done
sleep 10
# start rt-app