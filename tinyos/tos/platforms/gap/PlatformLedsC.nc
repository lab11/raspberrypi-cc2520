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

  components new LinuxLedP("gap:red:usr1") as l1;
  components new LinuxLedP("gap:green:usr0") as l0;
  components new LinuxLedP("gap:blue:usr2") as l2;

  Led0 = l0.GeneralIO;
  Led1 = l1.GeneralIO;
  Led2 = l2.GeneralIO;
}
