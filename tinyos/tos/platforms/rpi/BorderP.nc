/*
 * @author: Brad Campbell <bradjc@umich.edu>
 */

#include "border.h"

module BorderP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
  }
  uses {
    interface ForwardingTable;
  }
}

implementation {

  struct in6_addr all_routers;
  struct in6_addr dhcp_server;
  struct in6_addr tun_ll;

  command error_t SoftwareInit.init() {
   // struct in6_addr dhcp6_group;

    // add a default route through the linux network interface
    call ForwardingTable.addRoute(NULL,
                                  0,
                                  NULL,
                                  ROUTE_IFACE_TUN);

    // Add a route for all routers address.
    inet_pton6("ff02::2", &all_routers);
    call ForwardingTable.addRoute(all_routers.s6_addr,
                                  128,
                                  NULL,
                                  ROUTE_IFACE_TUN);


    // Add a route for dhcp server requests. Without this route the node will
    // broadcast these on the radio, and there is no dhcp server out there.
    inet_pton6("ff02::1:2", &dhcp_server);
    call ForwardingTable.addRoute(dhcp_server.s6_addr,
                                  128,
                                  NULL,
                                  ROUTE_IFACE_TUN);

    // Add a route for the link local address for the tun interface.
    // This is most useful for DHCP messages so we can unicast the response.
    inet_pton6("fe80::212:aaaa:bbbb:ffff", &tun_ll);
    call ForwardingTable.addRoute(tun_ll.s6_addr,
                                  128,
                                  NULL,
                                  ROUTE_IFACE_TUN);

    return SUCCESS;
  }

}
