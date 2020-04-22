BEGIN {
  got_it = 0;
  zeroes = 0;
  nonzeroes = 0;
#cmd: ./perf stat -a --cpu 1 -e cycles:I -I 10 --per-core --verbose -o perf.dat  ./perf_test.x -w sleep -c 1 -t 1 --duty_cycle 0.10 > tmp.txt
# sample output
#
#     0.423657708 S0-C1           1           14133159      cycles:I
#     0.433739583 S0-C1           1           10956237      cycles:I
#     0.443821198 S0-C1           1                  0      cycles:I
#     0.453899531 S0-C1           1                  0      cycles:I
# 
#   on kernels where the exclude idle code doesn't properly keep track of event time_enabled/time_running we'll see:
#     0.432356927 S0-C1           1           19547554      cycles:I
#     0.443553021 S0-C1           1      <not counted>      cycles:I
#     0.454854166 S0-C1           1      <not counted>      cycles:I


}

/S.-C1.* cycles:I/{
  val = $(NF-1);
  if (val == "counted>" || val == 0) {
    zeroes += 1;
  } else if (val > 0) {
    nonzeroes += 1;
  }
}
END {
  if (nonzeroes > 0 && zeroes > 0) {
    printf("Got lines with both zero counts (%d) and nonzero counts (%d)\n", zeroes, nonzeroes);
    printf("THis is what is expected\n");
    printf("PASSED\n");
  } else {
    if (zeroes == 0) {
      printf("Didn't get any lines with zero counts. Either the cpu is never idle or exclude idle is not working\n");
      printf("Also, you may need patch https://review-android.quicinc.com/#/c/796641/ \n");
    }
    if (nonzeroes == 0) {
      printf("Didn't get any lines with nonzero counts. maybe perf_test.x failed to run or perf failed?\n");
    }
    printf("Exclude idle test failed\nMight need https://review-android.quicinc.com/#/c/1890598/\n");
    printf("FAILED\n");
  }
}

