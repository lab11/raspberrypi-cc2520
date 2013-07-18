#include "Timer.h"
#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>

module BlipQuickPacketP {
	uses {
		interface Leds;
    interface Boot;

    interface SplitControl as BlipControl;
    interface UDP as Udp;
    interface ForwardingTable;
  }
}
implementation {

#define RECEIVER "2001:470:1f10:1320::2"
#define PORT 4001
//uint16_t PORT = 0xf0AA;

#define ALL_ROUTERS "ff02::2"

  struct sockaddr_in6 dest; // Where to send the packet
  struct in6_addr next_hop;

  event void Boot.booted() {
    inet_pton6(RECEIVER, &dest.sin6_addr);
    dest.sin6_port = htons(PORT);

   call BlipControl.start();
  }

  event void BlipControl.startDone (error_t error) {
    error_t err;
    uint32_t data;

    inet_pton6(ALL_ROUTERS, &next_hop);
    call ForwardingTable.addRoute(dest.sin6_addr.s6_addr, 128, &next_hop,
      ROUTE_IFACE_154);

    // Set the payload as the pkt data
    data = 0xCABEBEED;

    err = call Udp.sendto(&dest, &data, 3);
    if (err != SUCCESS) {
    }
  }

  event void BlipControl.stopDone (error_t error) {
  }

  event void Udp.recvfrom (struct sockaddr_in6 *from,
                           void *data,
                           uint16_t len,
                           struct ip6_metadata *meta) { }
}
