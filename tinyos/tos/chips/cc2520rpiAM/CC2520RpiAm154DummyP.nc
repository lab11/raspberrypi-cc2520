
module CC2520RpiAm154DummyP {
  uses {
    interface BareSend as Ieee154Send;
    interface BareReceive as Ieee154Receive;
  }
}

implementation {
  event message_t* Ieee154Receive.receive(message_t* msg) { return msg; }
  event void Ieee154Send.sendDone(message_t* msg, error_t error) { }
}
