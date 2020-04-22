BEGIN {
  excl_idle_str = ", exclude_idle = 1,";
  got_it = 0;
  # event : name = cycles:I, , size = 112, { sample_period, sample_freq } = 4000, sample_type = IP|TID|TIME|CPU|PERIOD, disabled = 1, inherit = 1, exclude_idle = 1,
}

/# event : name = cycles:I,/{
  if (index($0, excl_idle_str) > 1) {
    printf("got '%s' in perf output header so perf accepted the exclude_idle attribute.\n", excl_idle_str);
    printf("PASSED\n");
    got_it = 1;
  }
}
END {
  if (got_it == 0) {
    printf("did not find %s\n", excl_idle_str);
    printf("did not find '%s' in perf output header so perf probably rejected the exclude_idle attribute.\n", excl_idle_str);
    printf("Exclude idle test failed\nMight need https://review-android.quicinc.com/#/c/1890598/\n");
    printf("FAILED\n");
  }
}
