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
  components HplBcm2835GeneralIOC as GeneralIOC;

  components new Bcm2835GpioC() as Led0Impl;
  components new Bcm2835GpioC() as Led1Impl;
  components new Bcm2835GpioC() as Led2Impl;

  Init = PlatformP.LedsInit;

  Led0Impl.IO -> GeneralIOC.Port1_07;
  Led1Impl.IO -> GeneralIOC.Port1_12;
  Led2Impl.IO -> GeneralIOC.Port1_13;

  Led0 = Led0Impl;
  Led1 = Led1Impl;
  Led2 = Led2Impl;
}
