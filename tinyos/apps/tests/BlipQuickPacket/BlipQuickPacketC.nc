
configuration BlipQuickPacketC {}
implementation {

	components MainC;
  components BlipQuickPacketP as App;
  components LedsC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;

  // IPv6 Stack
  components IPStackC;
  App.RadioControl -> IPStackC.SplitControl;
  components new UdpSocketC() as Udp;
  App.Udp -> Udp.UDP;

}
