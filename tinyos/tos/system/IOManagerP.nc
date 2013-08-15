#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/select.h>
#include <unistd.h>
#include <errno.h>
#include "debug_printf.h"

module IOManagerP {
  provides {
    interface IO[uint8_t id];
    interface BlockingIO;
  }
}

implementation {

  enum {
    N_FDS = uniqueCount("FILEID"),
  };

  uint8_t map[N_FDS];
  fd_set  rfds;
  bool is_init = FALSE;


  command error_t IO.registerFileDescriptor[uint8_t id] (int file_descriptor) {
    IOMANAGER_PRINTF("registering file descriptor %i for %i.\n", id,
      file_descriptor);
    if (!is_init) {
      memset(map, 0x01, sizeof(uint8_t) * N_FDS);
      is_init = TRUE;
    }
    atomic map[id] = file_descriptor;
    return SUCCESS;
  }

  command error_t IO.unregisterFileDescriptor[uint8_t id] (int fd) {
    IOMANAGER_PRINTF("unregistering file descriptor %i for %i.\n", id, fd);
    if (!is_init) return EOFF;
    // Set the file descriptor back to 1 to remove it
    atomic map[id] = 1;
    return SUCCESS;
  }

  async command void BlockingIO.waitForIO () {
    int     ret;
    int     i;
    uint8_t nfds = 0;

    // Clear the struct and set all fd that aren't 1
    FD_ZERO(&rfds);
    for (i=0; i<N_FDS; i++) {
      if (map[i] != 1) {
        FD_SET(map[i], &rfds);
        if (map[i] + 1 > nfds) {
          nfds = map[i] + 1;
        }
      }
    }

    // This blocks and is how we sleep!
    ret = select(nfds, &rfds, NULL, NULL, NULL);

    if (ret < 0) {
      if (errno == EINTR) {
        // suppress
      } else {
        // error
        ERROR("select return error: %i\n", ret);
      }

    } else if (ret == 0) {
      ERROR("select return 0.\n");

    } else {
      // some file is ready
      int j;

      if (ret > 1) {
        IOMANAGER_PRINTF("select finds %i file descriptors ready\n", ret);
      }
      for (j=0; j<N_FDS; j++) {
        if (FD_ISSET(map[j], &rfds)) {
          signal IO.receiveReady[j]();
        }
      }
    }
  }

  default async event void IO.receiveReady[uint8_t id] () { }

}
