#include "Timer.h"

 #include <stdio.h>

#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>

#define COLLECTION_SERVER "2001:470:1f10:131c::2"
#define WSN_ROOT "2607:f018:800a:bcde:f012:3456:7891:1"

module NodeCollectP @safe() {
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as MilliTimer;

    interface SplitControl as RadioControl;
    interface UDP as UDPService;
  }
}
implementation {

  uint16_t counter = 0;

  struct sockaddr_in6 server;
  struct sockaddr_in6 root;

  event void Boot.booted() {
    inet_pton6(COLLECTION_SERVER, &server.sin6_addr);
    server.sin6_port = htons(2001);
    inet_pton6(WSN_ROOT, &root.sin6_addr);
    root.sin6_port = htons(2001);

    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call UDPService.bind(2001);
      call MilliTimer.startPeriodic(1000);

    } else {
      call RadioControl.start();
    }
  }

  event void MilliTimer.fired() {
    counter++;
    if (counter % 2) {
      call Leds.led0Toggle();
      call UDPService.sendto(&server, &counter, 2);
    } else {
   //   call Leds.led1Toggle();
   //   call UDPService.sendto(&root, &counter, 2);
    }
  }

  event void UDPService.recvfrom (struct sockaddr_in6 *from,
                                  void *payload,
                                  uint16_t len,
                                  struct ip6_metadata *meta) {
    call Leds.led2Toggle();
  }

  event void RadioControl.stopDone (error_t e) { }

}
