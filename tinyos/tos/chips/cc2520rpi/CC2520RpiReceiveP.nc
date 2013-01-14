#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>

module CC2520RpiReceiveP {

  provides {
    interface Init as SoftwareInit @exactlyonce();

    interface BareReceive;
  }



}

implementation {

  int ret;
  pthread_t receive_thread;

  tasklet_norace message_t* rxMsg;
  message_t rxMsgBuffer;

  int cc2520_file;

  cc2520_header_t* getHeader (message_t* msg) {
  //  return ((void*)msg) + call Config.headerLength(msg);
    return ((void*)msg);
  }

  void* getPayload (message_t* msg) {
  //  return ((void*)msg)  + call RadioPacket.headerLength(msg);
    return msg->data;
  }

  void* receive (void* arg) {
    char buf[512];
    char pbuf[2048];
    char *buf_ptr = NULL;
    int i;
    uint8_t* data;

    printf("receive_thread\n");



    // Continuously receive packets
    while (1) {
      printf("Receiving a test message...\n");
      ret = read(cc2520_file, buf, 127);


    //  buf = (char*) rxMsg;
      if (ret > 0) {
        buf_ptr = pbuf;
        for (i = 0; i < ret; i++) {
          buf_ptr += sprintf(buf_ptr, " 0x%02X", buf[i]);
        }
        *(buf_ptr) = '\0';
        printf("read %s\n", pbuf);

        //memcpy(rxMsg, buf, ret);

        getHeader(rxMsg)->length = (uint8_t) buf[0];

        data = getPayload(rxMsg);

        memcpy(data, buf+1, ret-1);

        rxMsg = signal BareReceive.receive(rxMsg);
      }
    }

//    printf("Turning off the radio...\n");
//    ioctl(file_desc, CC2520_IO_RADIO_OFF, NULL);

//    close(file_desc);



    return NULL;
  }

  command error_t SoftwareInit.init() {
    // Open the character device for the CC2520
    cc2520_file = open("/dev/radio", O_RDWR);

    ret = pthread_create(&receive_thread, NULL, &receive, NULL);
    if (ret) {
      //error
    }

    rxMsg = &rxMsgBuffer;

    return SUCCESS;

  }



}
