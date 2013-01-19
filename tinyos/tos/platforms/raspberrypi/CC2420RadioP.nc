
module CC2420RadioP {
  provides {
    interface PacketAcknowledgements;
    interface PacketLink;
  }
  uses {
    interface PacketMetadata;
  }
}

implementation {

  async command error_t PacketAcknowledgements.requestAck(message_t* msg) {
    return call PacketMetadata.requestAck(msg);
  }

  async command error_t PacketAcknowledgements.noAck(message_t* msg) {
    return call PacketMetadata.noAck(msg);
  }

  async command bool PacketAcknowledgements.wasAcked(message_t* msg) {
    return call PacketMetadata.wasAcked(msg);
  }

  command void PacketLink.setRetries(message_t *msg, uint16_t maxRetries) {
    return call PacketMetadata.setRetries(msg, maxRetries);
  }

  command void PacketLink.setRetryDelay(message_t *msg, uint16_t retryDelay) {
    return call PacketMetadata.setRetryDelay(msg, retryDelay);
  }

  command uint16_t PacketLink.getRetries(message_t *msg) {
    return call PacketMetadata.getRetries(msg);
  }

  command uint16_t PacketLink.getRetryDelay(message_t *msg) {
    return call PacketMetadata.getRetryDelay(msg);
  }

  command bool PacketLink.wasDelivered(message_t *msg) {
    return call PacketMetadata.wasAcked(msg);
  }

}
