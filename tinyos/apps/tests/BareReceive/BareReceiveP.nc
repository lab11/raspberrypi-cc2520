#include "message.h"
#include "Ieee154.h"
#include "ieee154_header.h"

module BareReceiveP {
	uses {
		interface Leds;
    interface Boot;

    interface SplitControl as RadioControl;
    interface Packet as RadioPacket;
    interface Send as RadioSend;
    interface Receive as RadioReceive;
  }
}
implementation {

  message_t msg;
  struct ieee154_frame_addr out_frame;
  struct ieee154_frame_addr ack_frame;
  uint8_t* payload_buf = (uint8_t*) &msg;

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone (error_t error) {
  }

  event void RadioSend.sendDone (message_t* message, error_t error) {
  }

  event message_t* RadioReceive.receive(message_t* packet,
                                        void* payload, uint8_t len) {

    int i;
    printf("got packet (%i): 0x", len);
    for (i=0; i<len; i++) {
      printf("%02x", ((uint8_t*) payload)[i]);
    }
    printf("\n");

    return packet;
  }

  event void RadioControl.stopDone (error_t error) {
  }

}
