
module Interrupt2P {
  uses {
    interface Boot;
    interface GpioInterrupt as Int;
    interface Timer<TMilli> as TimerMilliC;
    interface Leds;
    interface HplBcm2835GeneralIO as Pin;
  }
}

implementation {

  uint8_t p = 0;

  event void Boot.booted() {
    call Pin.makeInput();
    call Int.enableRisingEdge();
    call TimerMilliC.startPeriodic(250);
  }

  async event void Int.fired () {
    call Leds.led1Toggle();
  }

  event void TimerMilliC.fired () {
    call Leds.led0Toggle();
  }

}
