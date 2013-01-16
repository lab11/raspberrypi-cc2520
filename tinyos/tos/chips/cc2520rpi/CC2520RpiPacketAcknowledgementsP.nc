

module CC2520RpiPacketAcknowledgementsP {
  provides {
    interface PacketAcknowledgements;
  }
}

implementation {


  async command error_t PacketAcknowledgements.requestAck(message_t* msg) {

    return SUCCESS;
  }

  async command error_t PacketAcknowledgements.noAck(message_t* msg) {
    return SUCCESS;
  }

  async command bool PacketAcknowledgements.wasAcked(message_t* msg) {
    return TRUE;
  }



}
