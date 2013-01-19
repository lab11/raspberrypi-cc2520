#include "Timer.h"

 #include <stdio.h>

#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>


module NodeP @safe() {
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as MilliTimer;

    interface SplitControl as RadioControl;
    interface UDP as UDPService;

    interface ForwardingTable;
  }
}
implementation {

 // message_t packet;

  bool locked;
  uint16_t counter = 0;


  struct in6_addr random_dest;
  struct in6_addr llmc;

  event void Boot.booted() {
    inet_pton6("2001:638:709:1235::1", &random_dest);
    inet_pton6("ff02::1", &llmc);

    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {

    if (err == SUCCESS) {
      call ForwardingTable.addRoute(random_dest.s6_addr,
                                    128,
                                    llmc.s6_addr,
                                    ROUTE_IFACE_154);

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
    counter++;
    dbg("RadioCountToLedsC", "RadioCountToLedsC: timer fired, counter is %hu.\n", counter);
  //  if (locked) {
  //    return;
 //   } else {


    // link-local multicast
   //   inet_pton6("ff02::1", &dest.sin6_addr);

      // some other random address
     // inet_pton6("2001::1", &dest.sin6_addr);
      inet_pton6("2001:638:709:1235::1", &dest.sin6_addr);
      dest.sin6_port = htons(2001);

      call UDPService.sendto(&dest, &counter, 2);

    //  if (e == SUCCESS) {
      //  dbg("RadioCountToLedsC", "RadioCountToLedsC: packet sent.\n", counter);
       // locked = TRUE;
     // }
   // }
  }

  event void UDPService.recvfrom (struct sockaddr_in6 *from,
                                  void *payload,
                                  uint16_t len,
                                  struct ip6_metadata *meta) {
    uint16_t* c;


    c = (uint16_t*)payload;
    if (*c & 0x1) {
      call Leds.led0On();
    }
    else {
      call Leds.led0Off();
    }
    if (*c & 0x2) {
      call Leds.led1On();
    }
    else {
      call Leds.led1Off();
    }
    if (*c & 0x4) {
      call Leds.led2On();
    }
    else {
      call Leds.led2Off();
    }

  }



  event void RadioControl.stopDone (error_t e) { }

}




