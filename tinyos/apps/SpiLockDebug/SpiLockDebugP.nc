#include <stdio.h>

#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>

module SpiLockDebugP @safe() {
  uses {
    interface Boot;
    interface Leds;

    interface SplitControl as RadioControl;

    interface RootControl;

    interface Timer<TMilli> as Timer;
  }
}
implementation {

  event void Boot.booted() {
#ifdef RPL_ROUTING
    call RootControl.setRoot();
#endif
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call RadioControl.start();
    } else {
      call Timer.startOneShot(10000u);
    }
  }

  event void Timer.fired () {
    printf("DEBUG: stopping radio.\b");
    call RadioControl.stop();
  }

  event void RadioControl.stopDone (error_t e) {
    call RadioControl.start();
  }

}
