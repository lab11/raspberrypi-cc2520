
// This layer is responsible for the "raw" data from the
// the radio driver. Here, the header is a one byte length field
// and the payload is everything in the packet except for the
// length field and the two byte checksum at the end. The checksum
// is verified by the lower driver.

module CC2520RpiPacketP {
  provides {
    interface RadioPacket;
  }
}

implementation {

  async command uint8_t RadioPacket.headerLength (message_t* msg) {
    // sizeof (ieee154_simple_header_t) + sizeof(len) + 2
  //    return 12;
    // At this layer we have a 1 byte header: the length field
    return sizeof(cc2520_header_t);
  }

  async command uint8_t RadioPacket.payloadLength(message_t* msg) {
    // The "payload" length at this point is the entire packet
    // except for the length field and the crc at the end.
    // The length byte at the start of the packet does not count
    // itself.
    uint8_t len = ((cc2520packet_header_t*) msg->header)->cc2520.length;
  //return len - sizeof(crc_packet);
    return len - 2;
  }


  async command void RadioPacket.setPayloadLength(message_t* msg,
                                                  uint8_t length) {
    // This is the end call of a series of "setPayloadLength" calls.
    // Each layer adds its content or header to the total "payload"
    // length. At this point we add the crc check length to the total
    // before sending it to the driver.
    ((cc2520packet_header_t*) msg->header)->cc2520.length = length + 2;
    //*(((uint8_t*) msg->data) - 1) = length + 2;
  }

  async command uint8_t RadioPacket.maxPayloadLength() {
    // Max length in 802.15.4 is 128 minus 1 for the length field
    // and minus 2 for the crc field
    return 128 - sizeof(cc2520_header_t) - 2;
  }

  async command uint8_t RadioPacket.metadataLength(message_t* msg) {
    return 0;
  }

  async command void RadioPacket.clear(message_t* msg) {
    memset(msg, 0, sizeof(message_t));
  }

}
