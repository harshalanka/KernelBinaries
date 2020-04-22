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
  cpu_offline_time = 0;
  overtime_lines=0;
  del area2_errs[0];
  biggest_gap = 0;
  verbose = 0;
}
function extract_time(str) {
  split(str, xarr, "_");
  #printf("xtract xarr[1]= %s, xarr[2]= %s\n", xarr[1], xarr[2]);
  return xarr[2]+0.0;
}

/^cmdline: / {
  fl_typ = "perf_test.x";
  printf("fl_typ= %s\n", fl_typ);
}
/secs: set_gen_sys_file: .* write:hotplug|secs: set_gen_sys_file: .* write:online/ {
  if (fl_typ != "perf_test.x") {
    fl_typ = "perf_test.x";
    printf("fl_typ= %s\n", fl_typ);
  }
#_   33.390852_ secs: set_gen_sys_file: before write:hotplug/target filename: /sys/devices/system/cpu/cpu1/hotplug/target: '152'
#_   33.391171_ secs: set_gen_sys_file: after  write:hotplug/target filename: /sys/devices/system/cpu/cpu1/hotplug/target: '152'
  if (index($0, "before") > 0) { 
    i = 1;
    area += 1;
  } 
  else { i = 2; }

  tm_beg[area][i] = extract_time($0);
  printf("tm_beg[%d][%d]= '%f', ln= %s\n", area, i, tm_beg[area][i], $0);
}

/_.*_ ===> sched_setaffinity rc= -1, errno= 0x16, err= Invalid argument, wanted_mask= 0x2/ {
   cpu_offline_time = extract_time($0);
   printf("--> got cpu_offline_time = %f\n", cpu_offline_time);
}

match($0, /.* \[00.] .* cycles: .* .*|.* \[00.] .* cpu-clock: .* .*/) {
#     kworker/1:0    18 [001]    35.790599:     348260 cycles:  ffffff8008917868 _raw_spin_unlock_irq ([kernel.kallsyms])
  if (fl_typ != "perf") {
    fl_typ = "perf";
    printf("fl_typ= %s, area= %d\n", fl_typ, area);
      #printf("line doesn't contain '%s' nor '%s'.\nline: '%s'\nFAILED", enm[1], enm[2], $0);
  }
  if (area >= 1) {
    cpu_indx = index($0, "[")+1;
    cpu = substr($0, cpu_indx, 3)+0;
    cpu_indx += 5;
    tmp  = substr($0, cpu_indx);
    i = index(tmp, ":") - 1;
    tm = substr(tmp, 1, i) + 0.0;
    val = 1
    eindx= -1
    evt=""
    for (i=1; i <= 2; i++) {
       lk_for = " " enm[i] ": ";
       if (index($0, lk_for) > 1) {
          eindx = i;
          evt = enm[i];
          #printf("line contains '%s' lk_for='%s' line: '%s'\n", enm[i], lk_for, $0);
          break;
       }
    }

    if (eindx == -1) {
      printf("line doesn't contain '%s' nor '%s'.\nline: '%s'\nFAILED\n", enm[1], enm[2], $0);
      exit(1);
    }
    if (tm < tm_beg[2][2]) {
       area = 1;
    }
    else if (tm > tm_beg[3][1]) {
       area = 3;
    }
    else if (tm > tm_beg[2][2] && tm < tm_beg[3][1] && tm > cpu_offline_time) {
       area = 2;
    } else {
       next;
    }
    if (area >= 2 && tm_prv > 0) {
       gap = tm - tm_prv;
       if (biggest_gap < gap) {
         biggest_gap = gap;
         biggest_gap_tm[1] = tm_prv;
         biggest_gap_tm[2] = tm;
       }
    }
    tm_prv = tm;
    #printf("cpu= %d, tm='%f' area= %d evt= %s ln= %s\n", cpu, tm, area, evt, $0);
    if (val > 0) {
       nonzeroes[eindx][area] += 1;
    }
    if (area == 2 && val > 0) {
      area2_errs[length(area2_errs)+1] = $0;
      if(verbose > 1) {
        printf("nonzero while down: %f < T < %f: ln= %s\n", tm_beg[2][2], tm_beg[3][1], $0);
      }
    }

    #printf("%s %d\n", evt, val);
    overtime_lines += 1;
  }
}
END {
  printf("got overtime lines= %d\n", overtime_lines);
  did_prt_area2_errs = 0;
  ck[1] = ck[2] = ck[3] = 1;
  printf("biggest time gap= %f between T= %f and %f\n", biggest_gap, biggest_gap_tm[1], biggest_gap_tm[2]);
  use_biggest_gap = 0;
  if (biggest_gap > 0.1 && biggest_gap_tm[1] > tm_beg[2][2] && biggest_gap_tm[1] < tm_beg[3][1]) {
     # so it can take a long time to do hotplug.
     # we request 1 second of hotplug offline time
     # I've seen it take 100s of ms for the initial request to cpu actually going offline
     # So we'll continue to get samples during this long trying to offline interval
     # And I can't really tell when the cpu has gone offline.
     # The test is really trying to show that, if we take a cpu offline and bring it back up 
     # then do the events (hw & sw) get started back up?
     # This is a compromise then. If we see at least 0.1 seconds gap in samples between the 
     # 'request offline' and the 'request online' times then we assume that the cpu went offline
     # and ignore the samples during this interval.
     use_biggest_gap = 1;
     printf("It took %f seconds from the request offline to cpu going offline\n", 
       biggest_gap_tm[1] - tm_beg[2][1]);
     err = 0;
     i = 2;
     for (j = 1; j <= 2; j++) {
       if (nonzeroes[j][i]  > 0) { err = 1; }
     }
     if (err == 1) {
       printf("Ignoring samples in %s... assuming they are due to long time it took to go offline\n", anm[i]);
     }
  }
  err = 0;
  for (i = 1; i <= 3; i++) {
   for (j = 1; j <= 2; j++) {
     printf("section %s: zeroes= %2d, nonzeroes= %2d, evt= %s\n", anm[i], zeroes[j][i],  nonzeroes[j][i], enm[j]);
     if (i != 2 && (nonzeroes[j][i] == 0 || zeroes[j][i] > 0)) {
       ck[i] = 0;
       err = 1;
       printf("failed section %s\n", anm[i]);
       #exit(1);
     }
     if (i == 2 && use_biggest_gap == 0 && (nonzeroes[j][i]  > 0)) {
       ck[i] = 0;
       err = 1;
       printf("failed section %s: did not expect to see %s samples while cpu is down\n", anm[i], enm[j]);
       if (did_prt_area2_errs == 0) {
         printf("print first/last 10 lines in err\n");
         for (k= 1; k < length(area2_errs); k++) { printf("ln[%d]= %s\n", k, area2_errs[k]); if (k == 10) {break;}}
         m = length(area2_errs) -10; 
         if (m < 1) { m = 1;}
         for (k= m; k < length(area2_errs); k++) { printf("ln[%d]= %s\n", k, area2_errs[k]);}
         did_prt_area2_errs = 1;
       }
       #exit(1);
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

