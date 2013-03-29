
configuration UartTestC {
}

implementation {
  components UartTestP as AppP;
  components MainC;
  components LedsC;
  components UartC;

  AppP.Boot -> MainC.Boot;
  AppP.Leds -> LedsC;

  components new TimerMilliC();
  AppP.TimerMilliC -> TimerMilliC;

  AppP.UartBuffer -> UartC.UartBuffer;

}
