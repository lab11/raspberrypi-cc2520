
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

  char buf[512];
  char pbuf[2048];
  char *buf_ptr = NULL;
  uint8_t flag = 0;
  uint8_t len;

  uint8_t seq = 0;

  message_t* m;


  void* send (void* arg) {
    uint8_t i;
    uint8_t ret;
    printf("send_thread\n");


    // Open the character device for the CC2520
    cc2520_file = open("/dev/radio", O_RDWR);

    printf("cc2520file: %i\n", cc2520_file);

    // Continuously receive packets
    while (1) {
      printf("Waiting to send...\n");
      while (!flag) {
        i++;
        printf(".");
      }

      buf_ptr = pbuf;
      for (i = 0; i < len+1; i++) {
        buf_ptr += sprintf(buf_ptr, " 0x%02X", buf[i]);
      }
      *(buf_ptr) = '\0';
      printf("write %i, %s\n", len, pbuf);

      ret = write(cc2520_file, buf, len-1);
      printf("send ret %i\n", ret);
      signal BareSend.sendDone(m, SUCCESS);
      flag = 0;


    }




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
    uint8_t i;
    uint8_t* msgbuf = (uint8_t*) msg;

   // uint8_t len;
    printf("Send packet\n");

  //  len = ((uint8_t*) msg)[0];
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
    m = msg;
    flag = 1;

  //  signal BareSend.sendDone(msg, SUCCESS);
    return SUCCESS;
  }

  command error_t BareSend.cancel (message_t* msg) {
    return SUCCESS;
  }



}
