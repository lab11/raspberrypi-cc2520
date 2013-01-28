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
  components ThreadWaitC;

  McuSleepP.ThreadWait -> ThreadWaitC.ThreadWait;

  McuSleep = McuSleepP.McuSleep;
  McuPowerState = McuSleepP.McuPowerState;
  McuPowerOverride = McuSleepP.McuPowerOverride;

}
