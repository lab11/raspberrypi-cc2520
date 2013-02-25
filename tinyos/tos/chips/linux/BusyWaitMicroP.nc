
#include <time.h>
#include <errno.h>

module BusyWaitMicroP {
  provides {
    interface BusyWait<TMicro, uint16_t>;
  }
}

implementation {

  async command void BusyWait.wait (uint16_t dt) {
    struct timespec t;
    struct timespec rem;
    int ret;

    t.tv_sec = 0;
    t.tv_nsec = ((long) dt) * 1000;

    ret = nanosleep(&t, &rem);
    if (ret == -1) {
      if (errno == EINTR) {
        nanosleep(&rem, NULL);
      }
    }
  }

}
