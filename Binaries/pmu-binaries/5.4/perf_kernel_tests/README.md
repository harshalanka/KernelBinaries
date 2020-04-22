#### Perf Kernel Tests

This repo contains the binaries and scripts that test:
```
    the kernel is compiled with perf support,
    has a driver loaded, 
    accepts multiple cycle events, 
    accepts and uses the exclude_idle attribute,
    preserves events across hotplug
```
Both a 32bit and 64bit perf binary are included as well as a 32bit gawk binary.
The perf binaries come from https://github.qualcomm.com/pfay/perf_arm64 and
https://github.qualcomm.com/pfay/perf_arm32. The instructions to build the
binaries are in the repo too.

The .sh script contains a brief description of the test (as comments).
If a test passes it will print:
```
PASSED
```
If a test fails it will print:
```
FAILED
```
Either the .sh file or the .awk script will contain reasons for possible false
FAILED cases. 
It will also print a CR or gerrit reference for what needs to be implemented.

#### To get what you need to run the tests (for android or kdev):
If you have a repo that allows .tar.gz files then you can use ./mk_distro.sh 
to package up all the files you need and then:
```
   1) grab perf_kernel_tests.tar.gz
   2) copy to target
   3) gzip -d -f perf_kernel_tests.tar
   4) tar xvf perf_kernel_tests.tar
```
Now you should see all the tst\_\*.sh/.awk scripts and binaries.

Otherwise, just copy the whole repo.



#### To run:
To run all the tests:
```
    sh tst_00_get_32bit_or_64bit_perf_binary.sh # this also does the extract above if the .tar.gz file is present
    sh tst_run_all.sh
```
To run a single test (say tst_30_hotplug.sh):
```
    sh tst_30_hotplug.sh
```
Test tst_00_get_32bit_or_64bit_perf_binary.sh is really a setup for all the other tests
and must be run first. It copies perf.32 or perf.64 to perf.

Each test is otherwise standalone but clearly, if something like tst_01_perf_pmu_loaded.sh fails 
(no pmu driver loaded) then everything after it probably will fail.


#### To make a .tar.gz file:
```
   sh mk_distro.sh # in the repo dir
```
