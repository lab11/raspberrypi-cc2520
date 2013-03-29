
module UartTestP {
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
  	printf("%s", buf);
  	call Leds.led2Toggle();
  }

  event void TimerMilliC.fired () {
    call Leds.led0Toggle();
  }
}
