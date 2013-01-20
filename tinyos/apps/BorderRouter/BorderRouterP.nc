#include "Timer.h"

 #include <stdio.h>

#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>



module BorderRouterP @safe() {
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as MilliTimer;

    interface SplitControl as RadioControl;
    interface UDP as UDPService;
  }
}
implementation {

 // message_t packet;

  bool locked;
  uint16_t counter = 0;


  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call UDPService.bind(2001);
      call MilliTimer.startPeriodic(1000);
    }
    else {
      call RadioControl.start();
    }
  }

  event void MilliTimer.fired() {
    error_t e;
    struct sockaddr_in6 dest;

    // Test transmission of blink packet data.
    counter++;
    inet_pton6("ff02::1", &dest.sin6_addr);
    dest.sin6_port = htons(2001);
    call UDPService.sendto(&dest, &counter, 2);
  }

  event void UDPService.recvfrom (struct sockaddr_in6 *from,
                                  void *payload,
                                  uint16_t len,
                                  struct ip6_metadata *meta) {

    printf("RCTLB: len %i\n", len);

  }



  event void RadioControl.stopDone (error_t e) { }

}




