#include "hardware.h"
#include <bcm2835.h>
#include <stdio.h>

module PlatformP {
  provides {
    interface Init;
  }
  uses {
    interface Init as LedsInit;
  }
}
implementation {
  command error_t Init.init() {
  	printf("[PlatformP]: Bringing system online...\n");
  	bcm2835_init();
	call LedsInit.init();
    return SUCCESS;
  }

  // Fallback interface for LEDs if LedsC is not
  // used. 
  default command error_t LedsInit.init() {
    return SUCCESS;
  }
}
