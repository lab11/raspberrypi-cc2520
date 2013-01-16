
module ReadLqiP {
  provides {
    interface ReadLqi;
  }
  uses {
    interface PacketMetadata;
  }
}

implementation {

  command uint8_t ReadLqi.readLqi(message_t *msg) {
    return call PacketMetadata.getLqi(msg);
  }

  command uint8_t ReadLqi.readRssi(message_t *msg) {
    return call PacketMetadata.getRssi(msg);
  }

}
