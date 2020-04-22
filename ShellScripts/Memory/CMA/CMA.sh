# !/system/bin/sh
set -x
MEMGRAB="/data/local/tmp/memgrab"
ALLOCATION=256
TARGET_FILE="trace.txt"

if [ -f /d/cma/cma-2/alloc ]; then
  CMA_REGION="/d/cma/cma-2"
elif [ -f /d/cma/cma-linux,cma/alloc ]; then
  CMA_REGION="/d/cma/cma-linux,cma"
else
  CMA_REGION="/d/cma/cma-secure_regi"
fi

HOME=/data/local/tmp
export TOOLS='/data/local/tmp/'
TARGET_BUFFER=60000

while getopts ":d:e:m:t:" opt
   do
     case $opt in
        d ) duration=$OPTARG;;
        e ) events=$OPTARG;;
        m ) MAX_ALLOCATION_MB=$OPTARG;;
        t ) TAG=$OPTARG;;
    esac
done

if [ -z $events ]; then
    events="cma:* migrate:*"
elif [ -n $events ] ; then
    events=$events
fi

if [ -z $duration ]; then
    duration=60
elif [ -n $duration ]; then
    duration=$duration
fi

if [ -z $MAX_ALLOCATION_MB ]; then
    MAX_ALLOCATION_MB=9
elif [ -n $MAX_ALLOCATION_MB ]; then
    MAX_ALLOCATION_MB=$MAX_ALLOCATION_MB
fi

if [ -n $TAG ]; then
  TARGET_FILE="trace_$TAG.txt"
fi

INITIAL_USED_CMA_PAGES=`cat $CMA_REGION/used`
MAX_CMA_PAGES=`cat $CMA_REGION/count`

req_event=`echo $events|busybox sed 's/,/ /g'`
echo "events is "$req_event""
echo "duration is "$duration""

#set the trace buffer size
settrace()
{
  if [ -d $HOME ] ; then
    rm -rf $HOME
  fi
  mkdir $HOME
  arch=`uname -a|grep -c aarch64`
  if [ $arch -lt 1 ] ; then
  TARGET_BUFFER=20000
  fi
  echo "TARGET_BUFFER: $TARGET_BUFFER"
  echo $TARGET_BUFFER > /d/tracing/buffer_size_kb
}

#Start the trace buffer
starttrace(){
  echo 3 > /proc/sys/vm/drop_caches
  echo > /sys/kernel/debug/tracing/set_event
  echo $events > /sys/kernel/debug/tracing/set_event
  echo 1 > /d/tracing/events/cma/enable
  echo 1 > /d/tracing/events/migrate/enable
  echo  > /sys/kernel/debug/tracing/trace
  echo 1 > /sys/kernel/debug/tracing/tracing_on
  echo "Starting trace..... "
}

#stop trace buffer
stoptrace()
{
  echo "Stopping trace..... "
  echo 0 > /sys/kernel/debug/tracing/tracing_on
  cat /sys/kernel/debug/tracing/trace > $HOME/$TARGET_FILE
}

run(){

  settrace
  starttrace

  if [ -f $MEMGRAB ];then
    chmod 777 /data/local/tmp/memgrab
    ./memgrab 0 100 &
  fi

  MAX_USER_ALLOCATION_PAGES=`expr $MAX_ALLOCATION_MB \* $ALLOCATION`

  if [ $MAX_CMA_PAGES -gt `expr $INITIAL_USED_CMA_PAGES \+ $MAX_USER_ALLOCATION_PAGES` ]; then

  # We do allocations ranging from 1MB to MAX_ALLOCATION_MB from a CMA region
    for j in `seq 1 $MAX_ALLOCATION_MB`; do

        echo "Allocating $j MB CMA Memory"
        ALLOCATION_PAGES=`expr $j \* $ALLOCATION`

        # Allocate pages from this CMA region
        echo $ALLOCATION_PAGES > $CMA_REGION/alloc
        USED_PAGES=`cat $CMA_REGION/used`

        if [ $USED_PAGES -eq `expr $INITIAL_USED_CMA_PAGES \+ $ALLOCATION_PAGES` ]; then
          echo "Allocation successful for $ALLOCATION_PAGES pages"
        else
          echo "Allocation failed for $ALLOCATION_PAGES pages"
        fi

        sleep 5

        # Free pages from this CMA region
        echo $ALLOCATION_PAGES > $CMA_REGION/free
        USED_PAGES=`cat $CMA_REGION/used`

        if [ $USED_PAGES -eq $INITIAL_USED_CMA_PAGES ]; then
          echo "Free successful for $ALLOCATION_PAGES pages"
        else
          echo "Free failed for $ALLOCATION_PAGES pages"
        fi

    done
  else
    echo "Not enough pages for $MAX_ALLOCATION_MB allocation"
  fi

  busybox killall memgrab
  stoptrace
}
run
