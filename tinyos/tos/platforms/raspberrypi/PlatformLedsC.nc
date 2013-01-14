#include "hardware.h"

configuration PlatformLedsC {
  provides {
    interface GeneralIO as Led0;
    interface GeneralIO as Led1;
    interface GeneralIO as Led2;

  }
  uses {
    interface Init;
  }
}
implementation {
  // PlatformP will now specifically
  // call the Init interface of PlatformLeds.
  components PlatformP;
  components HplRpiGeneralIOC as GeneralIOC;

  components new RpiGpioC() as Led0Impl;
  components new RpiGpioC() as Led1Impl;
  components new RpiGpioC() as Led2Impl;

  // Means that this configuration's Init is
  // equivilent to PlatformP.LedsInit. In practice
  // this means that when you assign an Init
  // function to PlatformLedsC, it's passed through
  // and used by the PlatformInit stuff.
  // (this is rediculously confusing for blinking LEDs =( )
  Init = PlatformP.LedsInit;

  Led0Impl.HplGeneralIO -> GeneralIOC.Port1_07;
  Led1Impl.HplGeneralIO -> GeneralIOC.Port1_12;
  Led2Impl.HplGeneralIO -> GeneralIOC.Port1_13;

  Led0 = Led0Impl;
  Led1 = Led1Impl;
  Led2 = Led2Impl;
}
