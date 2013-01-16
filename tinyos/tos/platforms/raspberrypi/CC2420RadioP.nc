
module CC2420RadioP {
  provides {
    interface Send;
    interface Receive;
  }
  uses {
    interface BareSend;
    interface BareReceive;
  }
}

implementation {

  command error_t Send.send (message_t* msg, uint8_t len) {
    return call BareSend.send(msg);
  }

  command error_t Send.cancel(message_t* msg) {
    return call BareSend.cancel(msg);
  }

  event void BareSend.sendDone(message_t* msg, error_t error) {
    signal Send.sendDone(msg, error);
  }

  command uint8_t Send.maxPayloadLength() {
    return 126;
  }

  command void* Send.getPayload(message_t* msg, uint8_t len) {
    return msg->data;
  }

  event message_t* BareReceive.receive(message_t* msg) {
    uint8_t len = ((uint8_t*) msg)[0];
    signal Receive.receive(msg, msg->data, len);
  }

}
