#include <time.h>

module UnixTimeP {
  provides {
    interface UnixTime;
  }
}

implementation {
  async command uint32_t UnixTime.getSeconds () {
    return (uint32_t) time(NULL);
  }

  async command uint64_t UnixTime.getMilliseconds () {
    int ret;
    struct timeval tv;
    uint64_t unix_time = 0;

    ret = gettimeofday(&tv, NULL);
    if (ret == 0) {
      unix_time = (((uint64_t) tv.tv_sec) * 1000) +
                  (((uint64_t) tv.tv_usec) / 1000);
    }
    return unix_time;
  }

  async command uint64_t UnixTime.getMicroseconds () {
    int ret;
    struct timeval tv;
    uint64_t unix_time = 0;

    ret = gettimeofday(&tv, NULL);
    if (ret == 0) {
      unix_time = (((uint64_t) tv.tv_sec) * 1000000) + ((uint64_t) tv.tv_usec);
    }
    return unix_time;
  }

}

