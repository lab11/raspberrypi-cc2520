#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <termios.h>

#include "file_helpers.h"
#include "uart.h"

module UartP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface UartBuffer;
    interface UartConfig;
  }
  uses {
    interface IO;
    interface UnixTime;
    interface HplBcm2835GeneralIO as RXPin;
  }
}

implementation {

  int uart_fd;
  uint8_t uart_buf[1024];
  uint32_t last_uart_len;

  struct termios tty_settings;

  task void uart_recv_task () {
    uint32_t len;
    uint64_t timestamp;

    atomic len =  last_uart_len;

    timestamp = call UnixTime.getMicroseconds();

    signal UartBuffer.receive(uart_buf, len, timestamp);
  }

  error_t configure_serial (uart_config_t* config) {
    int ret;
    speed_t spd;

    UART_PRINTF("setting serial options:\n");
    UART_PRINTF("    baud_rate: %i\n", config->baud_rate);
    UART_PRINTF("    min_bytes: %i\n", config->min_return);

    // Make sure the RX pin is set to the UART function.
    UART_PRINTF("configuring RX pin for UART\n");
    call RXPin.selectModuleFunc();

    switch (config->baud_rate) {
      case 0: spd = B0; break;
      case 50: spd = B50; break;
      case 75: spd = B75; break;
      case 110: spd = B110; break;
      case 134: spd = B134; break;
      case 150: spd = B150; break;
      case 200: spd = B200; break;
      case 300: spd = B300; break;
      case 600: spd = B600; break;
      case 1200: spd = B1200; break;
      case 1800: spd = B1800; break;
      case 2400: spd = B2400; break;
      case 4800: spd = B4800; break;
      case 9600: spd = B9600; break;
      case 19200: spd = B19200; break;
      case 38400: spd = B38400; break;
      case 57600: spd = B57600; break;
      case 115200: spd = B115200; break;
      case 230400: spd = B230400; break;
      default: return ESIZE;
    }

    cfsetospeed(&tty_settings, spd);
    cfsetispeed(&tty_settings, spd);

    tty_settings.c_lflag     = 0;
    tty_settings.c_cc[VMIN]  = config->min_return;
    tty_settings.c_cc[VTIME] = 0;

    ret = tcsetattr(uart_fd, TCSANOW, &tty_settings);
    if (ret == -1) {
      ERROR("Cannot store serial settings.\n");
      ERROR("%s\n", strerror(errno));
      return FAIL;
    }

    return SUCCESS;
  }

  command error_t SoftwareInit.init() {
    int ret;

    // http://raspberrypihobbyist.blogspot.com/2012/08/raspberry-pi-serial-port.html

    UART_PRINTF("Initializing the UART Driver.\n");
    UART_PRINTF("Opening the file /dev/ttyAMA0.\n");

    uart_fd = open("/dev/ttyAMA0", O_RDWR | O_NOCTTY);
    if (uart_fd == -1) {
      ERROR("Unable to open UART file. errno: %i\n", errno);
      ERROR("%s\n", strerror(errno));
      exit(1);
    }

    // Get the current configuration of the serial port.
    ret = tcgetattr(uart_fd, &tty_settings);
    if (ret == -1) {
      ERROR("Cannot access serial settings.\n");
      ERROR("%s\n", strerror(errno));
      exit(1);
    }

    // Make the end of the pipe we read from to check if the packet was acked,
    // etc., nonblocking. This prevents the application from locking up with a
    // spurious select() return.
    //make_nonblocking(uart_fd);

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

    if (ret == 1 && uart_buf[0] == '\n') {
      //suppress this because who wants a new line?
      // Probably need to come back and look at if this is a good solution.
      return;
    }

    atomic last_uart_len = ret;

    // Post a task to trigger sendDone so we can get out of the async
    post uart_recv_task();
  }

  command error_t UartConfig.setserial (uart_config_t* c) {
    return configure_serial(c);
  }

}
