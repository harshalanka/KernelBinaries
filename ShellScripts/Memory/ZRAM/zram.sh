#!/system/bin/bash
TCID="zram.sh"

source zram_lib.sh

run_zram () {
echo "--------------------"
echo "running zram tests"
echo "--------------------"
bash zram01.sh
echo ""
bash zram02.sh
}

check_prereqs

# check zram module exists
MODULE_PATH=/lib/modules/`uname -r`/kernel/drivers/block/zram/zram.ko
if [ -f $MODULE_PATH ]; then
	run_zram
elif [ -b /dev/block/zram0 ]; then
	run_zram
else
	echo "$TCID : No zram.ko module or /dev/block/zram0 device file not found"
	echo "$TCID : CONFIG_ZRAM is not set"
	exit 1
fi
