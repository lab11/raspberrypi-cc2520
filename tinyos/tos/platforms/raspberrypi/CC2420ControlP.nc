
// Translation layer for CC2420Config to CC2520 until BLIP updates

module CC2420ControlP {
  provides {
    interface CC2420Config;
  }
  uses {
    interface RadioAddress;
  }
}

implementation {

  command error_t CC2420Config.sync() {
    signal CC2420Config.syncDone(SUCCESS);
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

}
