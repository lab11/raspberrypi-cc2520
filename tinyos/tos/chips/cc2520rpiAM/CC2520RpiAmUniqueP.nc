
// Sets the sequence number

module CC2520RpiAmUniqueP {
  provides {
    interface BareSend as Send;
    interface Init;
  }
  uses {
    interface BareSend as SubSend;
  }
}

implementation {

  uint8_t seq_no;

  command error_t Init.init () {
    seq_no = TOS_NODE_ID << 4;
    return SUCCESS;
  }

  command error_t Send.send (message_t* msg) {
    uint8_t* msg_ptr = (uint8_t*) msg;
    msg_ptr[3] = seq_no++;
    return call SubSend.send(msg);
  }

  command error_t Send.cancel (message_t* msg) {
    return call SubSend.cancel(msg);
  }

  event void SubSend.sendDone (message_t* msg, error_t error) {
    signal Send.sendDone(msg, error);
  }

}
