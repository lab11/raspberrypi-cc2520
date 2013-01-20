
module CC2420RadioP {
  provides {
    interface PacketAcknowledgements;
    interface PacketLink;
    interface CC2420Config;
    interface ReadLqi;
  }
  uses {
    interface PacketMetadata;
    interface RadioAddress;
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

  command error_t CC2420Config.sync() {
    signal CC2420Config.syncDone(SUCCESS);
    return SUCCESS;
  }

  command uint8_t CC2420Config.getChannel() {
    return 26;
  }

  command void CC2420Config.setChannel(uint8_t channel) {
  }

  command ieee_eui64_t CC2420Config.getExtAddr() {
    return call RadioAddress.getExtAddr();
  }

  async command uint16_t CC2420Config.getShortAddr() {
    return call RadioAddress.getShortAddr();
  }

  command void CC2420Config.setShortAddr(uint16_t address) {
    call RadioAddress.setShortAddr(address);
  }

  async command uint16_t CC2420Config.getPanAddr() {
    return call RadioAddress.getPanAddr();
  }

  command void CC2420Config.setPanAddr(uint16_t address) {
    call RadioAddress.setPanAddr(address);
  }

  command void CC2420Config.setAddressRecognition(bool enableAddressRecognition,
                                                  bool useHwAddressRecognition) {
  }

  async command bool CC2420Config.isAddressRecognitionEnabled() {
    return TRUE;
  }

  async command bool CC2420Config.isHwAddressRecognitionDefault() {
    return TRUE;
  }

  command void CC2420Config.setAutoAck(bool enableAutoAck, bool hwAutoAck) {
  }

  async command bool CC2420Config.isHwAutoAckDefault() {
    return TRUE;
  }

  async command bool CC2420Config.isAutoAckEnabled() {
    return TRUE;
  }

  command uint8_t ReadLqi.readLqi(message_t *msg) {
    return call PacketMetadata.getLqi(msg);
  }

  command uint8_t ReadLqi.readRssi(message_t *msg) {
    return call PacketMetadata.getRssi(msg);
  }

}
