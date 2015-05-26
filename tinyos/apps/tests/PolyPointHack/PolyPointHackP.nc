
#include <unistd.h>

module PolyPointHackP {
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

uint32_t count = 0;

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone (error_t error) {
  }

  event void RadioSend.sendDone (message_t* message, error_t error) {
  }

  event message_t* RadioReceive.receive(message_t* packet,
                                        void* payload, uint8_t len) {

    char *msg;
    /*
    int i;
    printf("%05i got packet (%i): 0x", count++, len);
    for (i=0; i<len; i++) {
      printf("%02x", ((uint8_t*) payload)[i]);
    }
    printf("\n");
    */

    msg = (char*) payload + 26;
    if (msg[len-26-1] != '!') {
      printf("# Corrupted packet. Skip.\n");
    }
    msg[len-26-1] = '\0';
    printf("%s\n", msg);

    return packet;
  }

  event void RadioControl.stopDone (error_t error) {
  }

}
