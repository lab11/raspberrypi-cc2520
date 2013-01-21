
// app for a data collection node in a wsn

configuration NodeCollectC {}
implementation {
  components MainC, NodeCollectP as App, LedsC;
  components new TimerMilliC();

  App.Boot -> MainC.Boot;

  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;

  // Radio
  components IPStackC;
  components new UdpSocketC() as UDPService;
  App.RadioControl -> IPStackC.SplitControl;
  App.UDPService   -> UDPService.UDP;
 // App.ForwardingTable -> IPStackC.ForwardingTable;

#ifdef RPL_ROUTING
  components RPLRoutingC;
#endif

}


