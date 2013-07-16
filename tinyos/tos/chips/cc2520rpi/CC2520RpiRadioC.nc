
/* Top level radio driver module for a very bare radio interface for the CC2520
 * radio running on Linux. This driver expects nearly fully formed 802.15.4
 * packets including the physical layer length byte. This driver will set the
 * sequence number and handle packet retries on the send side, and add metadata
 * on the receive side.
 *
 * This driver provides interfaces compatible with the BLIP IPv6/6LoWPAN stack.
 * See http://docs.tinyos.net/tinywiki/index.php/BLIP_2.0_Platform_Support_Guide
 * for a little more information on how these interfaces act.
 *
 * CC2520RpiRadioC stack:
 *          RadioP
 *        /     \
 *      V        \
 *    LinkP       \
 *      |          \
 *      V          V
 *    SendP      ReceiveP
 */

configuration CC2520RpiRadioC {
  provides {
    interface SplitControl;

    interface Send;
    interface Receive;
    interface Packet;
    interface LowPowerListening;
    interface PacketMetadata;
    interface Ieee154Address;
  }
}

implementation {
  components CC2520RpiRadioP;
  components CC2520RpiLinkC;
  components CC2520RpiReceiveC;
  components CC2520RpiSendC;
  components LocalIeeeEui64C;

  CC2520RpiRadioP.LocalIeeeEui64 -> LocalIeeeEui64C.LocalIeeeEui64;

  CC2520RpiRadioP.SubSend -> CC2520RpiLinkC.Send;
  CC2520RpiRadioP.SubReceive -> CC2520RpiReceiveC.BareReceive;

  CC2520RpiLinkC.SubSend -> CC2520RpiSendC.BareSend;

  SplitControl      = CC2520RpiRadioP.SplitControl;
  Send              = CC2520RpiRadioP.Send;
  Receive           = CC2520RpiRadioP.Receive;
  Packet            = CC2520RpiRadioP.Packet;
  LowPowerListening = CC2520RpiRadioP.LowPowerListening;
  PacketMetadata    = CC2520RpiRadioP.PacketMetadata;
  Ieee154Address    = CC2520RpiRadioP.Ieee154Address;
}
