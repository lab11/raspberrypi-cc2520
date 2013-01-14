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

  int cc2520_file;

  char buf[256];
  uint8_t send_buf[256];
  char pbuf[2048];
  char *buf_ptr = NULL;
  uint8_t flag = 0;
  uint8_t len;

  uint8_t seq = 0;

  message_t* msg_pointer;

  pthread_t       thread_send;
  pthread_mutex_t mutex_send;
  pthread_cond_t  cond_send;


  void* send (void* arg) {
    uint8_t local_len;

    printf("send_thread\n");

    // Forever loop waiting for packets to send
    while (1) {
      pthread_cond_wait(&cond_send, &mutex_send);

      // copy the packet to a local buffer
      local_len = len;
      memcpy(send_buf, buf, local_len-1);

      // don't need the lock any more
      pthread_mutex_unlock(&mutex_send);

      // call the driver to send the packet
      write(cc2520_file, send_buf, local_len-1);

      // signal that we are done
      signal BareSend.sendDone(msg_pointer, SUCCESS);
    }

    return NULL;
  }



  command error_t SoftwareInit.init() {
    int ret;

    // Open the character device for the CC2520
    cc2520_file = open("/dev/radio", O_RDWR);

    printf("cc2520file: %i\n", cc2520_file);


    // Create a pthread mutex
    // This isn't used really, but is required for the condition variable the
    //  send() thread uses to wait for a queued packet.
    ret = pthread_mutex_init(&mutex_send, NULL);
    if (ret) {
      // error and die
    }

    // Create a condition variable
    // This is used for the send() thread to wait on until a packet is ready to
    //  be transmitted.
    ret = pthread_cond_init(&cond_send, NULL);
    if (ret) {
      // error and die
    }

    // Create the send thread
    ret = pthread_create(&thread_send, NULL, &send, NULL);
    if (ret) {
      //error
    }

    return SUCCESS;
  }

  command error_t BareSend.send (message_t* msg) {
    uint8_t i;
    uint8_t* msgbuf = (uint8_t*) msg;
    uint8_t ret;

    pthread_mutex_lock(&mutex_send);

    printf("Send packet\n");

    len = 15;
    memcpy(buf, msgbuf+11, len);
    buf[0] = len;
    buf[1] |= 0x20; // request ack
   // buf[2] = 0x88;
    buf[3] = seq++;
    printf("Send packet %i\n", len);

    buf_ptr = pbuf;
    for (i = 0; i < len; i++) {
      buf_ptr += sprintf(buf_ptr, " 0x%02X", buf[i]);
    }
    *(buf_ptr) = '\0';
    printf("swrite %s\n", pbuf);
    msg_pointer = msg;

    pthread_cond_signal(&cond_send);
    pthread_mutex_unlock(&mutex_send);

    return SUCCESS;
  }

  command error_t BareSend.cancel (message_t* msg) {
    return SUCCESS;
  }



}
