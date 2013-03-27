#include "hardware.h"
#include <bcm2835.h>
#include "debug_printf.h"
#include <signal.h>

extern void signal_wrapper(int, void*);

module PlatformP {
  provides {
    interface Init;
  }
  uses {
    interface Init as LedsInit;
    interface Leds;
  }
}
implementation {

  void sigint_handler (int sig) {
    RPI_PRINTF("Shuting down.\n");
    call Leds.led0Off();
    call Leds.led1Off();
    call Leds.led2Off();

    exit(0);
  }

  command error_t Init.init() {

    setvbuf(stdout, NULL, _IONBF, 0);

    RPI_PRINTF("Bringing system online.\n");
    bcm2835_init();
    call LedsInit.init();

    RPI_PRINTF("Setting SIGINT signal handler.\n");
    signal_wrapper(SIGINT, sigint_handler);

    return SUCCESS;
  }

  // Fallback interface for LEDs if LedsC is not
  // used.
  default command error_t LedsInit.init() {
    return SUCCESS;
  }
}
