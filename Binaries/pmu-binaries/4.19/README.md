# perf_tests

The repo contains the following test cases:

## 1. perf_kernel_tests
Basic functional tests of the perf features that QCOM has added on top.
For more info., go through the Readme inside the directory.

## 2. perf_hp_loop.sh
Indefinite functional test to validate perf hotplug feature. The test case creates an event to count the CPU-1's clock cycles.
The count is made to read continuously for every 200 ms. In parallel, the CPU-1 is made to alternate between online and offline
every two seconds. Hence, the output should be counts displayed for two seconds and "not counted" displayed for the next two seconds.
This process repeats indefinitely.

**To run**
```bash
sh ./perf_hp_loop.sh
```

## 3. perf_stress.sh
If performs a stress test on the perf-core and the ARM PMU framework. The test excercises the following paths:
* Creation and deletion of perf counting events
* Creation and deletion of perf sampling events
* perf-hotplug feature
* Interrupt path of the PMU driver
* Multiplexing of perf events

All the above mentioned cases are executed in parallel

**To run**
```bash
sh ./perf_stress.sh
```
