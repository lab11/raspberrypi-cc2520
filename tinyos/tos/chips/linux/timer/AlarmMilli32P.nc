#include <signal.h>
#include <time.h>

generic module AlarmMilli32P() {
  provides {
    interface Init;
    interface Alarm<TMilli, uint32_t> as Alarm;
  }
}

implementation {
  timer_t  timerid;

  // Keep track of the absolute time the most recent alarm was set at.
  // This is for the getAlarm() function.
  uint32_t last_alarm;

  // Callback for the alarm
  void AlarmMilli32Fired (int sig) {
    signal Alarm.fired();
  }

  command error_t Init.init () {
    int t_ret;

    // Create a timer that just keeps counting
    // http://www.kernel.org/doc/man-pages/online/pages/man2/timer_create.2.html
    t_ret = timer_create(CLOCK_MONOTONIC, NULL, &timerid);

    //sighandler_t brad_signal(int, sighandler_t);
    __nesc_keyword_signal(SIGALRM, AlarmMilli32Fired);

    last_alarm = 0;

    if (t_ret == 0) {
      return SUCCESS;
    } else {
      return FAIL;
    }
  }

  async command void Alarm.start (uint32_t dt) {
    call Alarm.startAt(call Alarm.getNow(), dt);
  }

  async command void Alarm.stop () {
    struct itimerspec new_timer = {{0, 0}, {0, 0}};
    timer_settime(timerid, TIMER_ABSTIME, &new_timer, NULL);
  }

  async command bool Alarm.isRunning () {
    struct itimerspec timer_val;
    int               t_ret;
    // if timer_val.it_value is 0, then the timer is disarmed
    t_ret = timer_gettime(timerid, &timer_val);
    if (t_ret == 0) {
      if (timer_val.it_value.tv_sec == 0 && timer_val.it_value.tv_nsec == 0) {
        return FALSE;
      }
      return TRUE;
    }
    return FALSE;
  }

  async command void Alarm.startAt(uint32_t t0, uint32_t dt) {
    struct timespec timer_val;
    int             t_ret;
    uint32_t        time_now;
    uint32_t        elapsed;

    atomic {
      t_ret = clock_gettime(CLOCK_MONOTONIC, &timer_val);

      if (t_ret == 0) {

        // save the alarm time
        last_alarm = t0 + dt;

        // get the time now in milliseconds
        time_now = (timer_val.tv_sec * 1000) + (timer_val.tv_nsec / 1000000);

        elapsed = time_now - t0;

        if (elapsed >= dt) {
          // we requested an alarm for a time that already happened
          // trigger an alarm in 0.5 ms

          struct itimerspec new_timer = {{0, 0}, {0, 0}};

          new_timer.it_value.tv_sec  = timer_val.tv_sec;
          new_timer.it_value.tv_nsec = timer_val.tv_nsec + 500000;

          t_ret = timer_settime(timerid, TIMER_ABSTIME, &new_timer, NULL);

        } else {
          // Set a new timer for the right time in the future
          uint32_t          remaining;
          struct itimerspec new_timer = {{0, 0}, {0, 0}};
          uint32_t          remaining_seconds;
          uint32_t          remaining_nanoseconds;

          remaining             = dt - elapsed;
          remaining_seconds     = remaining / 1000;
          remaining_nanoseconds = (remaining - (remaining_seconds * 1000)) * 1000000;

          new_timer.it_value.tv_sec  = timer_val.tv_sec + remaining_seconds;
          new_timer.it_value.tv_nsec = timer_val.tv_nsec + remaining_nanoseconds;

          if (new_timer.it_value.tv_nsec > 999999999) {
            // the number of nanoseconds add up to more than a second.
            new_timer.it_value.tv_nsec -= 999999999;
            new_timer.it_value.tv_sec++;
          }

          t_ret = timer_settime(timerid, TIMER_ABSTIME, &new_timer, NULL);
        }
        if (t_ret != 0) {
        //  printf("set timer failed\n");
        }

      }

    }
  }

  async command uint32_t Alarm.getNow () {
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

  async command uint32_t Alarm.getAlarm () {
    atomic return last_alarm;
  }

}
