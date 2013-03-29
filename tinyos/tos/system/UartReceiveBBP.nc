
generic module UartReceiveBBP (uint32_t baud_rate) {
  provides {
    interface UartBuffer;

    interface Init;
  }
  uses {
    interface GeneralIO as UartRxPin;
    interface GpioInterrupt as UartRxInt;
    interface BusyWait<TMicro,uint16_t>;
    interface Leds;
  }
}

implementation {


  uint32_t baudPeriod = (1/baud_rate)*1000000;

  uint8_t buf[100];

  command error_t Init.init() {
  //  call UartRxPin.makeInput();
    call Leds.led1On();
    call UartRxInt.enableRisingEdge();
    return SUCCESS;
  }

  task void received_byte () {
    signal UartBuffer.receive(buf, 1);
  }

  async event void UartRxInt.fired() {
    int i;
    uint8_t byte;

    call Leds.led1Toggle();

    i = 0;
    byte = 0;
    call BusyWait.wait(baudPeriod*1.5);

    while (i < 8) {
      if (call UartRxPin.get()) {
        byte = byte | 0x01;
      } else {
        byte = byte & 0xFE;
      }
      byte = byte << 1;
      i++;

      call BusyWait.wait(baudPeriod);
    }
    memcpy(buf, &byte, 1);
    post received_byte();
  }

}
