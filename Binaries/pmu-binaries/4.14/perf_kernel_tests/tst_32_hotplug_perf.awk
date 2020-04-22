
BEGIN {

  if (hp_cpu == "") {
    hp_cpu="1";
  }
  if (non_hp_cpu == "") {
    non_hp_cpu="0";
  }
  if (soc == "") {
    soc=".";
  }
  sc_str0="S" soc "-C" non_hp_cpu ".* cycles";
  sc_str1="S" soc "-C" hp_cpu ".* cycles";
  printf("use pattern='%s' for non hotplug cycles event\n", sc_str0);
  printf("use pattern='%s' for hotplug cycles event\n", sc_str1);
  got_it = 0;
  hp_zeroes = 0;
  hp_nonzeroes = 0;
  hp_got_nonzeroes_after_zeroes = 0;
  zeroes = 0;
  nonzeroes = 0;
}

#/S0-C1.* cycles/{
$0 ~ sc_str1 {
  val = $(NF-1);
  if (val == "counted>" || val == 0) {
    hp_zeroes += 1;
  } else if (val > 0) {
    hp_nonzeroes += 1;
    if (hp_zeroes > 0) {
      # this shows that the nonzero counts started again after hotplug
      hp_got_nonzeroes_after_zeroes += 1;
    }
  }
}
#/S0-C0.* cycles/{
$0 ~ sc_str0 {
  val = $(NF-1);
  if (val == "counted>" || val == 0) {
    zeroes += 1;
  } else if (val > 0) {
    nonzeroes += 1;
  }
}
END {
  err=0;
  if (hp_nonzeroes > 0 && hp_zeroes > 0) {
    printf("The hotplugged cpu has lines with both zero counts (%d) and nonzero counts (%d)\n", hp_zeroes, hp_nonzeroes);
    printf("This is what is expected\n");
  } else {
    if (hp_zeroes == 0) {
      printf("The hotplugged cpu Didn't get any lines with zero counts. Did the hot-unplug not work?\n");
    }
    if (hp_nonzeroes == 0) {
      printf("The hotplugged cpu didn't get any lines with nonzero counts. Maybe ./perf_test.x failed to run or ./perf failed?\n");
    }
    err = 1;
  }
  if ( hp_got_nonzeroes_after_zeroes == 0) {
     printf("The hotplugged CPU didn't start counting again after hotplug in\n");
     err = 1;
  } else {
     printf("The hotplugged CPU did start counting again after hotplug in\n");
  }
  if (nonzeroes == 0 || zeroes > 0) {
    printf("The 'not hotplugged' cpu has lines with zero counts (%d) and no nonzero counts (%d)\n", zeroes, nonzeroes);
    printf("This is not what is expected\n");
    err = 1;
  } else {
    printf("The 'not hotplugged' cpu has no (%d) lines with zero counts and %d lines with nonzero counts\n", zeroes, nonzeroes);
    printf("This is what is expected\n");
  }
  if (err == 0) {
    printf("PASSED\n");
  } else {
    printf("hotplug test failed: might need https://review-android.quicinc.com/#/c/1890622/\n");
    printf("FAILED\n");
  }
}
