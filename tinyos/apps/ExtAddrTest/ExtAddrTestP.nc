module ExtAddrTestP {
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as Timer0;

    interface SplitControl as RadioControl;
    interface Packet as BarePacket;
    interface Send as Ieee154Send;
    interface Receive as Ieee154Receive;
    interface PacketLink;
  }
}

implementation {

  uint16_t counter = 0;
  uint8_t pkt[128];

  message_t* msg = (message_t*) pkt;

  event void Boot.booted() {
    // setup packet
    pkt[0] = 19; // length
    pkt[1] = 0x41; // no ack
    pkt[2] = 0x8C; // dest ext addr, src short
    pkt[3] = 0x00; // seq
    pkt[4] = 0x22; // pan id
    pkt[5] = 0x00;
    pkt[6] = 0x01; // dst ext addr
    pkt[7] = 0x00;
    pkt[8] = 0x00;
    pkt[9] = 0x00;
    pkt[10] = 0x00;
    pkt[11] = 0x00;
    pkt[12] = 0x00;
    pkt[13] = 0x00;
    pkt[14] = 0x01; // src sht addr
    pkt[15] = 0x00;
    pkt[16] = (counter & 0xFF);
    pkt[17] = (counter >> 8);

    call RadioControl.start();
  }

  event void RadioControl.startDone (error_t e) {
    if (e == SUCCESS) {
      call Timer0.startPeriodic(1000);
    } else {
      call RadioControl.start();
    }
  }

  event void Timer0.fired () {
    counter++;

    pkt[16] = (counter & 0xFF);
    pkt[17] = (counter >> 8);

    call Ieee154Send.send(msg, call BarePacket.payloadLength(msg));
    call Leds.led2Toggle();
  }

  event void Ieee154Send.sendDone (message_t *msgl, error_t error) { }

  event message_t* Ieee154Receive.receive (message_t *msgl,
                                           void *msg_payload,
                                           uint8_t len) {
  }

  event void RadioControl.stopDone (error_t error) {

  }

}
