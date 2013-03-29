
configuration UartC {
}

implementation {
  components UartP;
  components MainC;
  components LedsC;

  UartP.Boot -> MainC.Boot;
  UartP.Leds -> LedsC;

  components new TimerMilliC();
  UartP.TimerMilliC -> TimerMilliC;

  components HplBcm2835GeneralIOC as Hpl;
  components new Bcm2835GpioC() as BcmGpio;
  BcmGpio.IO -> Hpl.Port1_10;
  components Bcm2835InterruptC as IntC;

  components new UartReceiveBBC(9600);

  UartP.UartBuffer -> UartReceiveBBC.UartBuffer;
  UartReceiveBBC.UartRxPin -> BcmGpio.GeneralIO;
  UartReceiveBBC.UartRxInt -> IntC.Port1_10;

}
