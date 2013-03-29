
module UartP {
  uses {
  	interface Boot;
    interface Leds;
    interface Timer<TMilli> as TimerMilliC;
    interface UartBuffer;
  }
}
implementation {
  event void Boot.booted () {
  	call TimerMilliC.startPeriodic(3000);
  }

  event void UartBuffer.receive (uint8_t* buf, uint8_t len) {
  	printf("buffer: %i\n", buf[0]);
  	call Leds.led2Toggle();
  }

  event void TimerMilliC.fired () {
    call Leds.led0Toggle();
  }
}
