#include "hardware.h"
#include "debug_printf.h"
#include <signal.h>

module PlatformP {
  provides {
    interface Init;
  }
  uses {
    interface Init as GpioInit;
    interface Init as LedsInit;
    interface Init as InterruptInit;
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
    call GpioInit.init();
    call LedsInit.init();
    call InterruptInit.init();

    RPI_PRINTF("Setting SIGINT signal handler.\n");
    __nesc_keyword_signal(SIGINT, sigint_handler);

    return SUCCESS;
  }

  // Fallback interface for LEDs if LedsC is not
  // used.
  default command error_t LedsInit.init() {
    return SUCCESS;
  }

  default command error_t InterruptInit.init() {
    return SUCCESS;
  }
}
