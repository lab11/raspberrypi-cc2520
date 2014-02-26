
// generic app for a node in a wsn

configuration NodeC {}
implementation {
  components MainC, NodeP as App, LedsC;
  components new TimerMilliC();

  App.Boot -> MainC.Boot;

  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;

  // Radio
  components IPStackC;
  components new UdpSocketC() as UDPService;
  App.RadioControl -> IPStackC.SplitControl;
  App.UDPService   -> UDPService.UDP;

#ifdef RPL_ROUTING
  components RPLRoutingC;
#endif

}
