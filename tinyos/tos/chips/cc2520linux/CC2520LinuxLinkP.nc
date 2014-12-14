/*
 * Author: Miklos Maroti,
 * Author: Morten Tranberg Hansen
 * Author: Brad Campbell
 */

generic module CC2520RpiLinkP () {
  provides {
    interface BareSend as Send;
  }
  uses {
    interface BareSend as SubSend;
    interface PacketMetadata;
    interface Timer<TMilli> as DelayTimer;
  }
}

implementation {
  enum {
    STATE_READY = 0,
    STATE_SENDING = 1,
    STATE_SENDDONE = 2,
    STATE_SIGNAL = 4, // add error code
  };

  uint8_t state = STATE_READY;
  message_t *currentMsg;
  uint16_t totalRetries;


  // We do everything from a single task in order to call SubSend.send
  // and Send.sendDone only once. This helps inlining the code and
  // reduces the code size.
  //
  task void send() {
    uint16_t retries;

    retries = call PacketMetadata.getRetries(currentMsg);

    if (state == STATE_SENDDONE) {
      if (retries == 0 || call PacketMetadata.wasAcked(currentMsg)) {
        state = STATE_SIGNAL + SUCCESS;

      } else if (++totalRetries < retries) {
        uint16_t delay;

        state = STATE_SENDING;
        delay = call PacketMetadata.getRetryDelay(currentMsg);

        if (delay > 0) {
          call DelayTimer.startOneShot(delay);
          return;
        }

      } else {
        state = STATE_SIGNAL + FAIL;
      }
    }

    if (state == STATE_SENDING) {
      state = STATE_SENDDONE;

      if (call SubSend.send(currentMsg) != SUCCESS) {
        post send();
      }

      return;
    }

    if (state >= STATE_SIGNAL) {
      error_t error = state - STATE_SIGNAL;

      // do not update the retries count for non packet link messages
      if (retries > 0) {
        call PacketMetadata.setRetries(currentMsg, totalRetries);
      }

      state = STATE_READY;
      signal Send.sendDone(currentMsg, error);
    }
  }

  event void SubSend.sendDone(message_t* msg, error_t error) {
    if (error != SUCCESS) {
      state = STATE_SIGNAL + error;
    }

    post send();
  }

  event void DelayTimer.fired() {
    post send();
  }

  command error_t Send.send(message_t *msg) {
    if (state != STATE_READY) return EBUSY;

    // it is enough to set it only once
    if (call PacketMetadata.getRetries(msg) > 0) {
      call PacketMetadata.requestAck(msg);
    }

    currentMsg = msg;
    totalRetries = 0;
    state = STATE_SENDING;
    post send();

    return SUCCESS;
  }

  command error_t Send.cancel(message_t *msg) {
    if (currentMsg != msg || state == STATE_READY) {
      return FAIL;
    }

    // if a send is in progress
    if (state == STATE_SENDDONE) {
      call SubSend.cancel(msg);
    } else {
      post send();
    }

    call DelayTimer.stop();
    state = STATE_SIGNAL + ECANCEL;

    return SUCCESS;
  }

}
