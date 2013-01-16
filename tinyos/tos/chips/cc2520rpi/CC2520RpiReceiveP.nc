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

  message_t* rxMsg;
  message_t rxMsgBuffer;

  int cc2520_file;

  void* receive (void* arg) {
    char buf[512];
    char pbuf[2048];
    char *buf_ptr = NULL;
    int i;

    printf("receive_thread\n");

    // Continuously receive packets
    while (1) {
      printf("Receiving a test message...\n");
      ret = read(cc2520_file, buf, 127);

      if (ret > 0) {
        buf_ptr = pbuf;
        for (i = 0; i < ret; i++) {
          buf_ptr += sprintf(buf_ptr, " 0x%02X", buf[i]);
        }
        *(buf_ptr) = '\0';
        printf("read %i %s\n", ret, pbuf);

        // Copy the raw packet out of the character device buffer
        // Don't copy the 2 byte CRC
        memcpy((uint8_t*) rxMsg, buf, ret-2);

        rxMsg = signal BareReceive.receive(rxMsg);
      }
    }

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
