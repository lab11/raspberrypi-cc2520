#include "rpihardware.h"

module McuSleepP @safe() {
  provides {
    interface McuSleep;
    interface McuPowerState;
  }
  uses {
    interface McuPowerOverride;
    interface ThreadWait;
  }
}
implementation {

  mcu_power_t getPowerState() {
    return 0;
  }

  async command void McuSleep.sleep() {
    __nesc_enable_interrupt();
    call ThreadWait.wait();
  }

  async command void McuPowerState.update() {
  }

 default async command mcu_power_t McuPowerOverride.lowestState() {
   return 1;
 }

}
