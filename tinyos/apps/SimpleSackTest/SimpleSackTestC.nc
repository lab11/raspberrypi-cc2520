#include <Timer.h>
#include "SimpleSackTest.h"
#include "Ieee154.h"

module SimpleSackTestC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;

  uses interface Ieee154Send;
  uses interface Ieee154Packet;
  uses interface Packet;
  uses interface Receive as Ieee154Receive;
  uses interface SplitControl as RadioControl;

  uses interface CC2420Config;

  uses interface PacketAcknowledgements;

}
implementation {

  ieee154_saddr_t addr = 0x01;
  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;

  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
  }

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void Ieee154Send.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      call Leds.led1Toggle();
      if (call PacketAcknowledgements.wasAcked(msg)) {
        call Leds.led2Toggle();
      }
      busy = FALSE;
    }
  }

  event message_t* Ieee154Receive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      setLeds(btrpkt->counter);
    }
    return msg;
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call CC2420Config.setAutoAck(1,0);
      call CC2420Config.sync();
    }
    else {
      call RadioControl.start();
    }
  }

  event void CC2420Config.syncDone(error_t error){
     if (error == SUCCESS){
       call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
     }
     else{
       call CC2420Config.setAutoAck(1,0);   //enable auto-sw-acks
       call CC2420Config.sync();
     }
   }

  event void RadioControl.stopDone(error_t err) {

  }

  event void Timer0.fired() {
    counter++;
    if (!busy) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)
        (call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));

      if (btrpkt == NULL) {
	      return;
      }

      btrpkt->counter = counter;

      call PacketAcknowledgements.requestAck(&pkt);

      if (call Ieee154Send.send(addr, 
          &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }
}

