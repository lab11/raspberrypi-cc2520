

module CC2520RpiPacketP {
  provides {
    interface RadioPacket;
  }
}

implementation {

  async command uint8_t RadioPacket.headerLength (message_t* msg) {
    // sizeof (ieee154_simple_header_t) + sizeof(len) + 2
    return 12;
  }

  async command uint8_t RadioPacket.payloadLength(message_t* msg) {
    return ((uint8_t*) msg)[0] - 2;
    //return 100;
  }


  async command void RadioPacket.setPayloadLength(message_t* msg,
                                                  uint8_t length) {
  }

  async command uint8_t RadioPacket.maxPayloadLength() {
    return 100;
  }

  async command uint8_t RadioPacket.metadataLength(message_t* msg) {
    return 0;
  }

  async command void RadioPacket.clear(message_t* msg) {

  }




}
