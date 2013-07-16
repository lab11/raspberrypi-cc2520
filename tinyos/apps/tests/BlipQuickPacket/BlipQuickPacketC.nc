
configuration BlipQuickPacketC {}
implementation {

	components MainC;
  components BlipQuickPacketP as App;
  components LedsC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;

  // IPv6 Stack
  components IPStackC;
  App.BlipControl -> IPStackC.SplitControl;
  App.ForwardingTable -> IPStackC.ForwardingTable;
  components new UdpSocketC() as Udp;
  App.Udp -> Udp.UDP;

  components StaticIPAddressC;

}
