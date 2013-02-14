#include "rpihardware.h"

configuration McuSleepC @safe() {
  provides {
    interface McuSleep;
    interface McuPowerState;
  }
  uses {
    interface McuPowerOverride;
  }
}

implementation {
  components McuSleepP;
  components IOManagerC;

  McuSleepP.BlockingIO -> IOManagerC.BlockingIO;

  McuSleep = McuSleepP.McuSleep;
  McuPowerState = McuSleepP.McuPowerState;
  McuPowerOverride = McuSleepP.McuPowerOverride;

}
