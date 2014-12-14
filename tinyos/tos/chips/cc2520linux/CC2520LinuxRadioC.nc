
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

generic configuration CC2520LinuxRadioC (const char* char_dev_path) {
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
  components new CC2520LinuxRadioP(char_dev_path);
  components new CC2520LinuxLinkC();
  components new CC2520LinuxReceiveC(char_dev_path);
  components new CC2520LinuxSendC(char_dev_path);
  components LocalIeeeEui64C;

  CC2520LinuxRadioP.LocalIeeeEui64 -> LocalIeeeEui64C.LocalIeeeEui64;

  CC2520LinuxRadioP.SubSend -> CC2520LinuxLinkC.Send;
  CC2520LinuxLinkC.SubSend -> CC2520LinuxSendC.BareSend;

  CC2520LinuxRadioP.SubReceive -> CC2520LinuxReceiveC.BareReceive;

  CC2520LinuxReceiveC.PacketMetadata -> CC2520LinuxRadioP.PacketMetadata;
  CC2520LinuxLinkC.PacketMetadata -> CC2520LinuxRadioP.PacketMetadata;
  CC2520LinuxSendC.PacketMetadata -> CC2520LinuxRadioP.PacketMetadata;

  SplitControl      = CC2520LinuxRadioP.SplitControl;
  Send              = CC2520LinuxRadioP.Send;
  Receive           = CC2520LinuxRadioP.Receive;
  Packet            = CC2520LinuxRadioP.Packet;
  LowPowerListening = CC2520LinuxRadioP.LowPowerListening;
  PacketMetadata    = CC2520LinuxRadioP.PacketMetadata;
  Ieee154Address    = CC2520LinuxRadioP.Ieee154Address;
}
