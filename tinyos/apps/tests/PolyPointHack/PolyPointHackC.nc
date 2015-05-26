
configuration PolyPointHackC {}
implementation {

	components MainC;
  components PolyPointHackP as App;
  components LedsC;
  components Ieee154BareC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;

  // Radio
  // Uses a very bare radio interface.
  App.RadioControl -> Ieee154BareC.SplitControl;
  App.RadioSend -> Ieee154BareC.BareSend;
  App.RadioReceive -> Ieee154BareC.BareReceive;
  App.RadioPacket -> Ieee154BareC.BarePacket;

}
