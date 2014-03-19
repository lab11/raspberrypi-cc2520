#include "Timer.h"

#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>


module NodeP @safe() {
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as MilliTimer;

    interface SplitControl as RadioControl;
    interface UDP as UDPService;
  }
}
implementation {

  bool locked;
  uint16_t counter = 0;

  struct sockaddr_in6 dest;

  event void Boot.booted() {
    inet_pton6("2001:638:709:1235::1", &dest.sin6_addr);
    dest.sin6_port = htons(2001);

    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {

    if (err == SUCCESS) {
      call UDPService.bind(2001);
      call MilliTimer.startPeriodic(10000);
    } else {
      call RadioControl.start();
    }
  }

  event void MilliTimer.fired() {
    counter++;

    call UDPService.sendto(&dest, &counter, 2);
  }

  event void UDPService.recvfrom (struct sockaddr_in6 *from,
                                  void *payload,
                                  uint16_t len,
                                  struct ip6_metadata *meta) {
  }

  event void RadioControl.stopDone (error_t e) { }

}
