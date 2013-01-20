
// Top level for a very stripped radio interface.
//
// Designed for BLIP.
//
// Provides low level interfaces for the CC2520 on the RPI. The send interface
//  expects a fully formed 802.15.4 packet except for the sequence number.

configuration CC2520RpiRadioC {
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
  components CC2520RpiRadioP;
  components CC2520RpiLinkC;
  components CC2520RpiReceiveC;
  components CC2520RpiSendC;

  CC2520RpiRadioP.SubSend -> CC2520RpiLinkC.Send;
  CC2520RpiRadioP.SubReceive -> CC2520RpiReceiveC.BareReceive;

  CC2520RpiLinkC.SubSend -> CC2520RpiSendC.BareSend;

  SplitControl      = CC2520RpiRadioP.SplitControl;
  Send              = CC2520RpiRadioP.Send;
  Receive           = CC2520RpiRadioP.Receive;
  Packet            = CC2520RpiRadioP.Packet;
  LowPowerListening = CC2520RpiRadioP.LowPowerListening;
  PacketMetadata    = CC2520RpiRadioP.PacketMetadata;
  RadioAddress      = CC2520RpiRadioP.RadioAddress;
}
