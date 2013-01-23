#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>


module IOManagerP {
  provides {
    interface IO[uint8_t io_id];
    interface BlockingIO;
    interface TimerFired;
  }
  uses {
    interface TimerQuery;
  }
}

implementation {

  #define MAX_NUM_FD 10

  typedef struct {
    uint8_t id;
    uint8_t fd;
  } id_fd_map_t;

  id_fd_map_t map[MAX_NUM_FD];
  uint8_t num_fd = 0;
  uint8_t nfds = 0;

  fd_set rfds;

  command error_t IO.register[uint8_t io_id] (int file_descriptor) {
    if (num_fd >= MAX_NUM_FD) {
      return FAIL;
    }
    if (num_fd == 0) {
      FD_ZERO(&rdfs);
    }

    map[num_fd].id = io_id;
    map[num_fd].id = file_descriptor;
    num_fd++;

    FD_SET(file_descriptor, rdfs);

    if (file_descriptor >= nfds) {
      nfds = file_descriptor + 1;
    }
  }

  command void BlockingIO.waitForIO () {
    int ret;
    uint16_t timer_ms;
    struct timeval;

    // setup the timeout as the time until the next timer fires
    timer_ms = call TimerQuery.nextTimerTime();
    timeval.tv_sec = 0;
    timeval.tv_usec = ((long) timer_ms) * 1000;

    ret = select(nfds, &rfds, NULL, NULL, timeval);

    if (ret < 0) {
      // error
    } else if (ret == 0) {
      // timeout signal timer
      signal TimerFired.fired();
    } else {
      // some file is ready
      int i;
      for (i=0; i<num_fd; i++) {
        if (FD_ISSET(map[i].fd, &rdfs)) {
          signal IO.receiveReady[map[i].id]();
        }
      }
    }
  }


}
