#include <unistd.h>
#include <fcntl.h>

#include "file_helpers.h"

module UartP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface UartBuffer;
  }
  uses {
    interface IO;
  }
}

implementation {

  int uart_fd;
  uint8_t uart_buf[1024];
  uint32_t last_uart_len;

  task void uart_recv_task () {
    uint32_t len;

    atomic len =  last_uart_len;

    signal UartBuffer.receive(uart_buf, len);
  }

  command error_t SoftwareInit.init() {

    // http://raspberrypihobbyist.blogspot.com/2012/08/raspberry-pi-serial-port.html

    UART_PRINTF("Initializing the UART Driver.\n");
    UART_PRINTF("Opening the file /dev/ttyAMA0.\n");

    uart_fd = open("/dev/ttyAMA0", O_RDWR);
    if (uart_fd == -1) {
      ERROR("Unable to open UART file. errno: %i\n", errno);
      ERROR("%s\n", strerror(errno));
      exit(1);
    }

    // Make the end of the pipe we read from to check if the packet was acked,
    // etc., nonblocking. This prevents the application from locking up with a
    // spurious select() return.
    make_nonblocking(uart_fd);

    // Add the packet send result pipe to the select() call
    call IO.registerFileDescriptor(uart_fd);

    return SUCCESS;
  }

  async event void IO.receiveReady () {
    ssize_t ret;

    ret = read(uart_fd, uart_buf, 1024);
    if (ret == -1) {
      switch (errno) {
        case EAGAIN:
          // This appears to be a spurious call from select() that shouldn't
          // really happen but does. Because this fd is nonblocking, the read()
          // returned with -1 and we should just go back to sleeping.
          // If there is really data here, select() will trigger this again.
          UART_PRINTF("spurious select wakeup.\n");
          return;
        default:
          ERROR("Error with packet result fifo. errno: %i\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
      }
    }

    atomic last_uart_len = ret;

    // Post a task to trigger sendDone so we can get out of the async
    post uart_recv_task();
  }

}
