#include <time.h>

#include "Timer.h"

module LocalTimeMilli32P {
	provides interface LocalTime<TMilli> as LocalTime;
}
implementation {

  async command uint32_t LocalTime.get() {
    struct timespec timer_val;
    int             t_ret;
    uint32_t        time_now = 0;

    t_ret = clock_gettime(CLOCK_MONOTONIC, &timer_val);

    if (t_ret == 0) {
      // get the time now in milliseconds
      time_now = (timer_val.tv_sec * 1000) + (timer_val.tv_nsec / 1000000);
    }

    return time_now;
  }

}


