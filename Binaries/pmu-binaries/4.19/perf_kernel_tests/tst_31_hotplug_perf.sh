#!/bin/sh

./perf record -a --cpu 1 -e cycles,cpu-clock ./perf_test.x -w hotplug --alt_list u1,d1,u1 -t 3 -m 0 -C 1 -v > tmp.txt
grep 'master: iter=' tmp.txt
#_  147.072309_ elap secs= 0.207376, master: iter= 0 of 3
#_  148.310365_ elap secs= 1.445432, master: iter= 1 of 3
#_  149.499330_ elap secs= 2.634377, master: iter= 2 of 3
grep 'secs: set_gen_sys_file: .* write:hotplug' tmp.txt

./perf script > tmp1.jnk

./gawk -f tst_31_hotplug_perf.awk tmp.txt tmp1.jnk

