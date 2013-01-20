
/**
 * Temporary hack to make BLIP work without modifications. This provides the
 * necessary CC2420 interface to make BLIP happy.
 *
 * When BLIP finally gets updated to use a generic IEEE15.4/Bare radio interface
 * this won't be necessary.
 */

configuration CC2420RadioC {
  provides {
    interface SplitControl;

    interface Send as BareSend;
    interface Receive as BareReceive;
    interface Packet as BarePacket;

    interface PacketAcknowledgements;
    interface LowPowerListening;
    interface PacketLink;

    interface CC2420Config;
    interface ReadLqi;
  }
}
implementation {

  components CC2420RadioP;
  components CC2520RpiRadioBareC;

  CC2420RadioP.PacketMetadata -> CC2520RpiRadioBareC.PacketMetadata;
  CC2420RadioP.RadioAddress -> CC2520RpiRadioBareC.RadioAddress;

  SplitControl = CC2520RpiRadioBareC.SplitControl;
  BareSend = CC2520RpiRadioBareC.Send;
  BareReceive = CC2520RpiRadioBareC.Receive;
  BarePacket = CC2520RpiRadioBareC.Packet;

  PacketAcknowledgements = CC2420RadioP.PacketAcknowledgements;
  PacketLink = CC2420RadioP.PacketLink;
  LowPowerListening = CC2520RpiRadioBareC.LowPowerListening;

  CC2420Config = CC2420RadioP.CC2420Config;
  ReadLqi = CC2420RadioP.ReadLqi;
}
