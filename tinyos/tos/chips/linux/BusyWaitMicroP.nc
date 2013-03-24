#include <sys/time.h>

module BusyWaitMicroP {
  provides {
    interface BusyWait<TMicro, uint16_t>;
  }
}

implementation {

  async command void BusyWait.wait (uint16_t dt) {
    struct timeval now, pulse;
    int micros;

    gettimeofday(&pulse, NULL);
    micros = 0;

    while (micros < (int) dt) {
       gettimeofday(&now, NULL);
       if (now.tv_sec > pulse.tv_sec) {
        micros = 1000000L;
      } else {
        micros = 0;
      }
       micros = micros + (now.tv_usec - pulse.tv_usec);
    }
  }

}
