
// Top level for a very stripped radio interface.
//
// Designed for BLIP.
//
// Provides low level interfaces for the CC2520 on the RPI. The send interface
//  expects a fully formed 802.15.4 packet except for the sequence number.

configuration CC2520RpiRadioBareC {
  provides {
    interface SplitControl;

    interface Send;
    interface Receive;
    interface Packet;
    interface LowPowerListening;
    interface PacketMetadata;
    interface RadioAddress;
  }
}

implementation {
  components CC2520RpiRadioBareP;
  components CC2520RpiSplitControlC;
  components CC2520RpiLinkC;
  components CC2520RpiReceiveC;
  components CC2520RpiSendC;

  CC2520RpiRadioBareP.SubSend -> CC2520RpiLinkC.Send;
  CC2520RpiRadioBareP.SubReceive -> CC2520RpiReceiveC.BareReceive;

  CC2520RpiLinkC.SubSend -> CC2520RpiSendC.BareSend;

  SplitControl      = CC2520RpiSplitControlC.SplitControl;
  Send              = CC2520RpiRadioBareP.Send;
  Receive           = CC2520RpiRadioBareP.Receive;
  Packet            = CC2520RpiRadioBareP.Packet;
  LowPowerListening = CC2520RpiRadioBareP.LowPowerListening;
  PacketMetadata    = CC2520RpiRadioBareP.PacketMetadata;
  RadioAddress      = CC2520RpiRadioBareP.RadioAddress;
}
