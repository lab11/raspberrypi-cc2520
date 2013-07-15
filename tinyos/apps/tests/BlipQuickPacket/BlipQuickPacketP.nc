#include "Timer.h"
#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>

module BlipQuickPacketP {
	uses {
		interface Leds;
    interface Boot;

    interface SplitControl as RadioControl;
    interface UDP as Udp;
  }
}
implementation {

#define RECEIVER "2001:470:1f10:131c::2"
#define PORT 4001

  struct sockaddr_in6 dest; // Where to send the packet

  event void Boot.booted() {
    inet_pton6(RECEIVER, &dest.sin6_addr);
    dest.sin6_port = htons(PORT);

    call RadioControl.start();
  }

  event void RadioControl.startDone (error_t error) {
    error_t err;
    uint8_t data;

    // Set the payload as the pkt data
    data = 1;

    err = call Udp.sendto(&dest, &data, 1);
    if (err != SUCCESS) {
      printf("sending packet failed.\n");
      printf("error: %i\n", err);
    }
  }

  event void RadioControl.stopDone (error_t error) {
  }

  event void Udp.recvfrom (struct sockaddr_in6 *from,
                           void *data,
                           uint16_t len,
                           struct ip6_metadata *meta) { }
}
