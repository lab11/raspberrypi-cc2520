#include "Timer.h"
#include "RadioCountToLeds154.h"

 #include <stdio.h>

/**
 * Implementation of the RadioCountToLeds application. RadioCountToLeds
 * maintains a 4Hz counter, broadcasting its value in an AM packet
 * every time it gets updated. A RadioCountToLeds node that hears a counter
 * displays the bottom three bits on its LEDs. This application is a useful
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
 */

module RadioCountToLeds154P @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface Ieee154Send;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as RadioControl;
    interface Packet as Ieee154Packet;
  }
}
implementation {

  message_t packet;

  bool locked;
  uint16_t counter = 0;

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call MilliTimer.startPeriodic(250);
    }
    else {
      call RadioControl.start();
    }
  }

  event void RadioControl.stopDone(error_t err) {
    // do nothing
  }

  event void MilliTimer.fired() {
    error_t e;
    counter++;
    dbg("RadioCountToLedsC", "RadioCountToLedsC: timer fired, counter is %hu.\n", counter);
    if (locked) {
      return;
    } else {
      radio_count_msg_t* rcm = (radio_count_msg_t*)
          call Ieee154Packet.getPayload(&packet, sizeof(radio_count_msg_t));
      if (rcm == NULL) {
        return;
      }

      rcm->counter = counter;
      e = call Ieee154Send.send(IEEE154_BROADCAST_ADDR,
                                &packet,
                                sizeof(radio_count_msg_t));
      if (e == SUCCESS) {
        dbg("RadioCountToLedsC", "RadioCountToLedsC: packet sent.\n", counter);
        locked = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr,
				                           void* payload,
                                   uint8_t len) {
  //  printf("RadioCountToLedsC", "Received packet of length %hhu.\n", len);
    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}
    else {
      radio_count_msg_t* rcm = (radio_count_msg_t*)payload;
      if (rcm->counter & 0x1) {
        call Leds.led0On();
      }
      else {
        call Leds.led0Off();
      }
      if (rcm->counter & 0x2) {
        call Leds.led1On();
      }
      else {
        call Leds.led1Off();
      }
      if (rcm->counter & 0x4) {
        call Leds.led2On();
      }
      else {
        call Leds.led2Off();
      }
      return bufPtr;
    }
  }

  event void Ieee154Send.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

}




