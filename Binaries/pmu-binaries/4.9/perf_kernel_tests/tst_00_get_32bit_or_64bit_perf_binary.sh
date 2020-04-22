#!/bin/sh

# this is not really a test.
# It just copies the 32bit or 64bit perf binary to the name 'perf' (which scripts expect to find in the cur dir)
arch=`uname -m`

flnm=perf_kernel_tests.tar

# gzip changes the file from the name:
#   perf_kernel_tests.tar.gz to perf_kernel_tests.tar
# So if you run this script more than once then the .gz file is gone.
# So allow for the case where just perf_kernel_test.tar is found.

if [ ! -f $flnm.gz ]; then
   if [ ! -f $flnm ]; then
   echo "warning: missing perf kernel tests tar gz file: $flnm.gz"
   echo "warning: You can generate this file by running 'sh mk_distro.sh' in the repo"
   echo "proceeding assuming that you've copied the whole repo"
   #exit
   fi
fi

if [ -f $flnm.gz ]; then
   gzip -f -d $flnm.gz
fi

if [ -f $flnm ]; then
   tar xvf $flnm
fi

if [ -f perf ]; then
   rm perf
fi

if [ "$arch" == "aarch64" ]; then
	cp perf.64 perf
else
	cp perf.32 perf
fi

cklst="perf gawk perf_test.x"
for i in $cklst; do
  if [ ! -f $i ]; then
	echo "failed to find $i binary. need $i in cur dir"
	echo "FAILED"
	exit
  fi
done
echo "PASSED"

