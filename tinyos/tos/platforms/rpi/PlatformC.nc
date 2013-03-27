/**
 * Initialization code
 *
 */
#include "hardware.h"

configuration PlatformC {
  provides {
    interface Init;
  }
}
implementation {
  components PlatformP;
  components LedsC;

  PlatformP.Leds -> LedsC;

  Init = PlatformP;
}
