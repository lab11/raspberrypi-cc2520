#include <pthread.h>
#include <stdio.h>

#include "CC2520RpiDriver.h"

module CC2520RpiSendP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface BareSend;
  }
  uses {
    interface Timer<TMilli> as Timer;
  }
}

implementation {

  int cc2520_file;


  uint8_t len;
  message_t* msg_pointer;

  uint8_t seq = 0;

  pthread_t       thread_send;
  pthread_mutex_t mutex_send;
  pthread_cond_t  cond_send;

  void* send (void* arg) {
    int ret;
    uint8_t *buf;

    printf("CC2520RpiSendP: send_thread starting.\n");

    while (1) {
      pthread_mutex_lock(&mutex_send);
      pthread_cond_wait(&cond_send, &mutex_send);

      buf = (uint8_t*)msg_pointer;

      // TODO: Fix this up to examine the product metadata.
      // buf[0] = len;
      buf[1] |= 0x20; // request ack
      // buf[2] = 0x88;
      buf[3] = seq++;

      // call the driver to send the packet
      ret = write(cc2520_file, buf, len-1);

      printf("CC2520RpiSendP: write DONE. return code: %d\n", ret);

      // TODO: Actually signal failures and other error conditions when the
      // packet hasn't been sent correctly. See the driver manual for more information.
      pthread_mutex_unlock(&mutex_send);

      signal BareSend.sendDone(msg_pointer, SUCCESS);
    }
  }

  command error_t SoftwareInit.init() {
    //int ret;

    // Open the character device for the CC2520
    cc2520_file = open("/dev/radio", O_RDWR);
    printf("cc2520file: %i\n", cc2520_file);
/*
    ret = pthread_mutex_init(&mutex_send, NULL);
    if (ret) {
      printf("CC2520RpiSendP: mutex creation failed.\n");
      exit(1);
    }

    // Create a condition variable
    // This is used for the send() thread to wait on until a packet is ready to
    //  be transmitted.
    ret = pthread_cond_init(&cond_send, NULL);
    if (ret) {
      printf("CC2520RpiSendP: mutex creation failed.\n");
      exit(1);
    }

    // Create the send thread
    ret = pthread_create(&thread_send, NULL, &send, NULL);
    if (ret) {
      printf("CC2520RpiSendP: thread creation failed.\n");
      exit(1);
    }
*/
    printf("CC2520RpiSendP: sizeof header: %i\n", sizeof(cc2520packet_header_t));

    return SUCCESS;
  }

  void print_message(uint8_t * buf, uint8_t plen)
  {
    uint8_t i;
    char pbuf[2048];
    char *buf_ptr = NULL;

    buf_ptr = pbuf;
    for (i = 0; i < plen-1; i++) {
      buf_ptr += sprintf(buf_ptr, " 0x%02X", buf[i]);
    }

    *(buf_ptr) = '\0';
    printf("CC2520RpiSendP: write %s\n", pbuf);
  }

  command error_t BareSend.send (message_t* msg) {
    uint8_t* buf;
    int ret;

    // NOTE: This currently isn't the best strategy
    // from a concurrency standpoint, and doesn't really
    // obey the standard TinyOS send contract. Examine this
    // later and see if it needs fixed up.

 //   pthread_mutex_lock(&mutex_send);
    printf("CC2520RpiSendP: sending packet\n");

    // Store the pointer and length of this message.
    msg_pointer = msg;
    len = *((uint8_t*)msg);

 //   printf("CC2520RpiSendP: Send packet %i bytes.\n", len);

    // Print the message to the console for now.
    print_message((uint8_t*)msg, len);

 //   pthread_cond_signal(&cond_send);
 //   pthread_mutex_unlock(&mutex_send);




    buf = (uint8_t*)msg;

    // TODO: Fix this up to examine the product metadata.
    // buf[0] = len;
    buf[1] |= 0x20; // request ack
    // buf[2] = 0x88;
    buf[3] = seq++;

    // call the driver to send the packet
    ret = write(cc2520_file, buf, len-1);
    if (ret < 0) {
      printf("CC2520RpiSendP: failed write()\n");
    }

    call Timer.startOneShot(100);

   // signal BareSend.sendDone(msg, SUCCESS);





    return SUCCESS;
  }

  event void Timer.fired () {
    signal BareSend.sendDone(msg_pointer, SUCCESS);
  }

  command error_t BareSend.cancel (message_t* msg) {
    return SUCCESS;
  }
}
