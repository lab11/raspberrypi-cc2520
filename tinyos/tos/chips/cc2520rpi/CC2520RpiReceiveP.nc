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


  void* receive (void* arg) {
    int cc2520_file;
    int ret;
    char buf[512];
    char pbuf[2048];
    char *buf_ptr = NULL;
    int i;

    printf("receive_thread\n");

    // Open the character device for the CC2520
    cc2520_file = open("/dev/radio", O_RDWR);

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
        printf("read %s\n", pbuf);
      }
    }

//    printf("Turning off the radio...\n");
//    ioctl(file_desc, CC2520_IO_RADIO_OFF, NULL);

//    close(file_desc);



    return NULL;
  }

  command error_t SoftwareInit.init() {
    int ret;
    pthread_t receive_thread;

    ret = pthread_create(&receive_thread, NULL, &receive, NULL);

    if (ret) {
      //error
    }

    return SUCCESS;

  }



}
