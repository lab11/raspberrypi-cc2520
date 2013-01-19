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

  radio_count_msg_t rcm;
  radio_count_msg_t* rcm_ptr;

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
    counter++;
    dbg("RadioCountToLedsC", "RadioCountToLedsC: timer fired, counter is %hu.\n", counter);
  //  if (locked) {
  //    return;
 //   } else {



      inet_pton6("ff02::1", &dest.sin6_addr);
      dest.sin6_port = htons(2001);

      rcm.counter = counter;
   //   call UDPService.sendto(&dest, &rcm, sizeof(radio_count_msg_t));

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

    if (len != sizeof(radio_count_msg_t)) {
      printf("RCTLB: bad len\n");
      return;
    } else {
      rcm_ptr = (radio_count_msg_t*)payload;
      if (rcm_ptr->counter & 0x1) {
        call Leds.led0On();
      }
      else {
        call Leds.led0Off();
      }
      if (rcm_ptr->counter & 0x2) {
        call Leds.led1On();
      }
      else {
        call Leds.led1Off();
      }
      if (rcm_ptr->counter & 0x4) {
        call Leds.led2On();
      }
      else {
        call Leds.led2Off();
      }
      return;
    }
  }



  event void RadioControl.stopDone (error_t e) { }

}




