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
  Init = PlatformP;
}
