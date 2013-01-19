
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

  command error_t SoftwareInit.init() {
   // struct in6_addr dhcp6_group;

    // add a default route through the linux network interface
    call ForwardingTable.addRoute(NULL, 0, NULL, ROUTE_IFACE_BORDER);

    return SUCCESS;
  }

}

