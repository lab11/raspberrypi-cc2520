
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
  components IPAddressC;
  components TunNameC;

  TunP.IO -> IOFileC.IO;

  // Anytime the IP address of the border router changes we need to know.
  // This will let us update the route to and ipv6 address of the TUN device.
  TunP.IPAddress -> IPAddressC.IPAddress;

  TunP.TunName -> TunNameC.TunName;

  MainC.SoftwareInit -> TunP.SoftwareInit;

  IPForward = TunP.IPForward;
}
