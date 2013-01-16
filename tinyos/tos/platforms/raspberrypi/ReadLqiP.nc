
module ReadLqiP {
  provides {
    interface ReadLqi;
  }
  uses {
    interface PacketField<uint8_t> as PacketLinkQuality;
    interface PacketField<uint8_t> as PacketRSSI;
  }
}

implementation {

  command uint8_t ReadLqi.readLqi(message_t *msg) {
    return call PacketLinkQuality.get(msg);
  }

  command uint8_t ReadLqi.readRssi(message_t *msg) {
    return call PacketRSSI.get(msg);
  }

}
