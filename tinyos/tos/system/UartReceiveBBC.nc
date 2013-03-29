
generic configuration UartReceiveBBC (uint32_t baud_rate) {
  provides {
    interface UartBuffer;
  }
  uses {
    interface GeneralIO as UartRxPin;
    interface GpioInterrupt as UartRxInt;
  }
}
implementation {
  components new UartReceiveBBP(baud_rate);
  components BusyWaitMicroC;
  components MainC;

  MainC.SoftwareInit -> UartReceiveBBP.Init;

  UartReceiveBBP.BusyWait -> BusyWaitMicroC.BusyWait;

  UartRxPin = UartReceiveBBP.UartRxPin;
  UartRxInt = UartReceiveBBP.UartRxInt;

  UartBuffer = UartReceiveBBP.UartBuffer;

  components LedsC;
  UartReceiveBBP.Leds -> LedsC;
}
