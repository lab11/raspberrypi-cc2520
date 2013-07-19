
/* Create an IPv6 TUN interface on Linux.
 *
 * This allows the TinyOS app to route IPv6 packets to the real Internet by
 * dumping them into the tun interface.
 *
 * This module also sets up a read on the incoming file descriptor so that
 * incoming packets that should be routed to the wireless sensor network
 * have an insertion point.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration TunC {
  provides {
    interface IPForward;
  }
}

implementation {
  components TunP;
  components MainC;
  components new IOFileC();
  components BRConfigC;

  TunP.IO -> IOFileC.IO;
  TunP.BRConfig -> BRConfigC.BRConfig;

  MainC.SoftwareInit -> TunP.SoftwareInit;

  IPForward = TunP.IPForward;
}
