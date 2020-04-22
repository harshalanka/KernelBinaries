BEGIN {
  area = 0;
  enm[1] =  "cpu-clock";
  enm[2] =  "cycles";
  anm[1] = "u1";
  anm[2] = "d1";
  anm[3] = "u1";
  for (i = 1; i <= 3; i++) {
   for (j = 1; j <= 2; j++) {
    nonzeroes[j][i] = 0;
    zeroes[j][i] = 0;
   }
  }
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
    if (evt == enm[2]) {eindx= 2;}
    if (eindx == -1) {
      printf("line doesn't contain '%s' nor '%s'.\nline: '%s'\nFAILED", enm[1], enm[2], $0);
      exit(1);
    }
    if (area == 2 && val > 0) {
       area = 3;
    }
    if (area == 1 && val == 0) {
       area = 2;
    }
    if (val > 0) {
       nonzeroes[eindx][area] += 1;
    }
    if (val == 0) {
       zeroes[eindx][area] += 1;
    }
    #printf("%s %d\n", evt, val);
    overtime_lines += 1;
  }
}
END {
  printf("got overtime lines= %d\n", overtime_lines);
  err=0;
  ck[1] = ck[2] = ck[3] = 1;
  for (i = 1; i <= 3; i++) {
   for (j = 1; j <= 2; j++) {
     printf("section %s: zeroes= %2d, nonzeroes= %2d, evt= %s\n", anm[i], zeroes[j][i],  nonzeroes[j][i], enm[j]);
     # make it a little more forgiving by doing zeroes > 1 (instead of > 0)
     if (i != 2 && (nonzeroes[j][i] == 0 || zeroes[j][i] > 1)) {
       ck[i] = 0;
       err = 1;
       printf("failed section %s\n", anm[i]);
     }
     # make it a little more forgiving by doing nonzeroes > 1 (instead of > 0)
     if (i == 2 && (nonzeroes[j][i]  > 1 || zeroes[j][i] == 0)) {
       ck[i] = 0;
       err = 1;
       printf("failed section %s\n", anm[i]);
     }
   }
  }
  if (err == 1) {
       printf("hotplug test failed: might need https://review-android.quicinc.com/#/c/1890622/\n");
       printf("FAILED\n");
  } else {
       printf("PASSED\n");
  }
}

