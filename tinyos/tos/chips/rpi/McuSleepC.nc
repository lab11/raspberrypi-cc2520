#include <pthread.h>
#include "rpihardware.h"

module McuSleepC @safe() {
  provides {
    interface McuSleep;
    interface McuPowerState;
  }
  uses {
    interface McuPowerOverride;
  }
}
implementation {




  mcu_power_t getPowerState() {

    return 0;
  }



  async command void McuSleep.sleep() {

  }

  async command void McuPowerState.update() {
  }

 default async command mcu_power_t McuPowerOverride.lowestState() {
   return 1;
 }

}
