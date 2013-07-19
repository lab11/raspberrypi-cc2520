/* Wire together the components needed to create a border router style packet
 * exit and entry point.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

#include "border.h"

configuration BorderC {
}

implementation {
  components BorderP;
  components TunC;

  components MainC;
  MainC.SoftwareInit -> BorderP.SoftwareInit;

  components IPForwardingEngineP;
  IPForwardingEngineP.IPForward[ROUTE_IFACE_TUN] -> TunC.IPForward;

  components IPStackC;
  BorderP.ForwardingTable -> IPStackC.ForwardingTable;

#ifdef RPL_ROUTING
  components RplBorderRouterP, IPPacketC;
  RplBorderRouterP.ForwardingEvents -> IPStackC.ForwardingEvents[ROUTE_IFACE_TUN];
  RplBorderRouterP.IPPacket -> IPPacketC.IPPacket;
#endif
}
