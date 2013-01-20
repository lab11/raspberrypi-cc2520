
module CC2520RpiAmPacketMetadataP {
  provides {
    interface PacketField<uint8_t> as PacketLinkQuality;
    interface PacketField<uint8_t> as PacketRSSI;
  }
  uses {
    interface PacketMetadata;
  }
}

implementation {


//----------------- PacketLinkQuality -----------------
  async command bool PacketLinkQuality.isSet(message_t* msg) {
    return TRUE;
  }

  async command uint8_t PacketLinkQuality.get(message_t* msg) {
    return call PacketMetadata.getLqi(msg);
  }

  async command void PacketLinkQuality.clear(message_t* msg) {
  }

  async command void PacketLinkQuality.set(message_t* msg, uint8_t value) {
    call PacketMetadata.setLqi(msg, value);
  }


//----------------- PacketRSSI -----------------
  async command bool PacketRSSI.isSet(message_t* msg) {
    return TRUE;
  }

  async command uint8_t PacketRSSI.get(message_t* msg) {
    return call PacketMetadata.getRssi(msg);
  }

  async command void PacketRSSI.clear(message_t* msg) {
  }

  async command void PacketRSSI.set(message_t* msg, uint8_t value) {
    call PacketMetadata.setRssi(msg, value);
  }

}
