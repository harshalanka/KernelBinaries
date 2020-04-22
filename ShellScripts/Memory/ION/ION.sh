#!/bin/bash

chmod +x ionapp_export
chmod +x ionapp_import

heapsize=4096
heaptype=25
TCID="ion_test.sh"
errcode=0

run_test()
{
	./ionapp_export -i $heaptype -s $heapsize &
	sleep 1
	./ionapp_import
	if [ $? -ne 0 ]; then
		echo "$TCID: heap_type: $heaptype result: Fail"
		errcode=1
	else
		echo "$TCID: heap_type: $heaptype result: Pass"
	fi
}

check_root()
{
	uid=$(id -u)
	if [ $uid -ne 0 ]; then
		echo $TCID: must be run as root >&2
		exit 0
	fi
}

check_device()
{
	DEVICE=/dev/ion
	if [ ! -e $DEVICE ]; then
		echo $TCID: No $DEVICE device found >&2
		echo $TCID: May be CONFIG_ION is not set >&2
		exit 0
	fi
}

main_function()
{

	while getopts ":s:t:" opt
   	do
     case $opt in
        s ) heapsize=$OPTARG;;
        t ) heaptype=$OPTARG;;
    esac
	done

	check_device
	check_root

	run_test

}

main_function

