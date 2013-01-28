
#define ROUTE_IFACE_BORDER 10

module BorderP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
  }
  uses {
    interface ForwardingTable;
  }
}

implementation {

  struct in6_addr dhcp_server;

  command error_t SoftwareInit.init() {
   // struct in6_addr dhcp6_group;

    // add a default route through the linux network interface
    call ForwardingTable.addRoute(NULL, 0, NULL, ROUTE_IFACE_BORDER);

    // Add a route for dhcp server requests. Without this the route will
    // broadcast these on the radio, and there is no dhcp server out there.
    inet_pton6("ff02::1:2", &dhcp_server);
    call ForwardingTable.addRoute(dhcp_server.s6_addr,
                                  128,
                                  NULL,
                                  ROUTE_IFACE_BORDER);

    return SUCCESS;
  }

}

