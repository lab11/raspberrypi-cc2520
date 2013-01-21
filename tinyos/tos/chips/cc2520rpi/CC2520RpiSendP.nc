#include <pthread.h>
#include <stdio.h>

#include "CC2520RpiDriver.h"

module CC2520RpiSendP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface BareSend;
  }
  uses {
    interface PacketMetadata;
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

  task void sendDone_task() {
    signal BareSend.sendDone(msg_pointer, SUCCESS);
  }

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
     // buf[1] |= 0x20; // request ack
      // buf[2] = 0x88;
      buf[3] = seq++;

      // call the driver to send the packet
      ret = write(cc2520_file, buf, len-1);
      switch (ret) {
        case CC2520_TX_BUSY:
        case CC2520_TX_ACK_TIMEOUT:
        case CC2520_TX_FAILED:
          call PacketMetadata.setWasAcked(msg_pointer, FALSE);
          break;
        case CC2520_TX_LENGTH:
          printf("CC2520RpiSendP: INCORRECT LENGTH\n");
          break;
        case CC2520_TX_SUCCESS:
          call PacketMetadata.setWasAcked(msg_pointer, TRUE);
          break;
        default:
          if (ret == len - 1) {
            call PacketMetadata.setWasAcked(msg_pointer, TRUE);
          } else {
            printf("CC2520RpiSendP: write() weird return code\n");
          }
          break;
      }

      printf("CC2520RpiSendP: write DONE. return code: %d\n", ret);
      pthread_mutex_unlock(&mutex_send);

      post sendDone_task();
    }

    return NULL;
  }

  command error_t SoftwareInit.init() {
    // Open the character device for the CC2520
    cc2520_file = open("/dev/radio", O_RDWR);
    printf("cc2520file: %i\n", cc2520_file);

    pthread_mutex_init(&mutex_send, NULL);
    pthread_cond_init(&cond_send, NULL);

    pthread_create(&thread_send, NULL, &send, NULL);

    printf("CC2520RpiSendP: sizeof header: %i\n", sizeof(cc2520packet_header_t));

    return SUCCESS;
  }

  command error_t BareSend.send (message_t* msg) {
    pthread_mutex_lock(&mutex_send);
    printf("CC2520RpiSendP: sending packet\n");

    // Store the pointer and length of this message.
    msg_pointer = msg;
    len = *((uint8_t*)msg);

    pthread_cond_signal(&cond_send);
    pthread_mutex_unlock(&mutex_send);

    return SUCCESS;
  }

  command error_t BareSend.cancel (message_t* msg) {
    return FAIL;
  }
}
