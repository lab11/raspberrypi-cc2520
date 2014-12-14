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
  // PlatformP will now specifically call the Init interface of PlatformLeds.
  components PlatformP;
  Init = PlatformP.LedsInit;

  components new LinuxLedP("aa") as l0;
  components new LinuxLedP("bb") as l1;
  components new LinuxLedP("cc") as l2;

  Led0 = l0.GeneralIO;
  Led1 = l1.GeneralIO;
  Led2 = l2.GeneralIO;
}
