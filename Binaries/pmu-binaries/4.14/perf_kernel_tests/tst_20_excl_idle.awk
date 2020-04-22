BEGIN {
  area = 0;
  anm[1] = "busy";
  anm[2] = "idle";
  enm[1] =  "cycles:I";
  zeroes = 0;
  nonzeroes = 0;
  overtime_lines=0;
}
/TimeStamp\tcpu\tgrp\tevt_num\ttm_run\ttm_ena\tevent\tcount/ {
  if (area == 0) {
    printf("got Timestamp line\n");
    area = 1;
  }
  next
}
{
  if (area >= 1 && length($0) < 3) {
    area = -1;
    next;
  }
  if (area >= 1) {
    val = $NF;
    gsub(/,/, "", val)
    val = val + 0;
    evt = $(NF-1);
    eindx= -1;
    if (evt == enm[1]) {eindx= 1;}
    if (eindx == -1) {
      printf("line doesn't contain '%s' nor '%s'.\nline: '%s'\nFAILED", enm[1], $0);
      exit(1);
    }
    if (val == 0) {
       zeroes += 1;
    }
    if (val > 0) {
       nonzeroes += 1;
    }
    overtime_lines += 1;
  }
}
END {
  printf("got overtime lines= %d\n", overtime_lines);
  printf("got %s lines with value zero\n", zeroes);
  printf("got %s lines with value > zero\n", nonzeroes);
  if (zeroes == 0) {
    printf("Test can falsely fail if something else is running on cpu 1\n");
    printf("Exclude idle test failed\nMight need https://review-android.quicinc.com/#/c/1890598/\n");
    printf("FAILED\n");
  } else {
    printf("PASSED\n");
  }
}

