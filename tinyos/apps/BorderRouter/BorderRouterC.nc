
configuration BorderRouterC {}
implementation {
  components MainC;
  components BorderRouterP as App;
  components LedsC;
  components new TimerMilliC();

  App.Boot -> MainC.Boot;

  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;


  // Radio
  components IPStackC;
  components new UdpSocketC() as UDPService;
  App.RadioControl -> IPStackC;
  App.UDPService   -> UDPService;

  components BorderC;
}


