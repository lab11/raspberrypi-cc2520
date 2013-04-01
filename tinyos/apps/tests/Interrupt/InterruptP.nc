
module InterruptP {
  uses {
    interface Boot;
    interface GpioInterrupt as Int;
    interface Timer<TMilli> as TimerMilliC;
    interface Leds;
  }
}

implementation {

  uint8_t p = 0;

  event void Boot.booted() {
    //call Int.enableRisingEdge();
    call Int.enableFallingEdge();
    call TimerMilliC.startPeriodic(250);
  }

  async event void Int.fired () {
    call Leds.led1Toggle();
  }

  event void TimerMilliC.fired () {
    call Leds.led0Toggle();
  }

}
