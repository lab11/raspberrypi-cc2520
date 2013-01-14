
#include <pthread.h>
#include <stdio.h>

#include "CC2520RpiDriver.h"

module CC2520RpiSendP {

  provides {
    interface Init as SoftwareInit @exactlyonce();

    interface BareSend;
  }



}

implementation {


  void* send (void* arg) {
    printf("send_thread\n");






    return NULL;
  }

  command error_t SoftwareInit.init() {
    int ret;
    pthread_t send_thread;

    ret = pthread_create(&send_thread, NULL, &send, NULL);

    if (ret) {
      //error
    }

    return SUCCESS;

  }

  command error_t BareSend.send (message_t* msg) {
    printf("Send packet\n");
    signal BareSend.sendDone(msg, SUCCESS);
    return SUCCESS;
  }

  command error_t BareSend.cancel (message_t* msg) {
    return SUCCESS;
  }



}
