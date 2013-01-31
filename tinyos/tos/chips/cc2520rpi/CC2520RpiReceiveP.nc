#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
//#include <signal.h>

/* This is the low level receive module that gets packets from the CC2520 kernel
 * module.
 */

module CC2520RpiReceiveP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface BareReceive;
  }
  uses {
    interface PacketMetadata;
  }
}

implementation {

  int cc2520_file;

  pthread_t receive_thread;

  bool pending = FALSE;
  pthread_mutex_t mutex_receive;
  pthread_cond_t cond_pending;

  message_t* rx_msg_ptr;
  message_t rx_msg_buf;

  uint8_t tsfer_buf[256];
  uint8_t tsfer_buf_len;

#ifdef CC2520RPI_DEBUG
  void print_message (uint8_t* buf, uint8_t len) {
    char pbuf[2048];
    char *buf_ptr = NULL;
    int i;

    buf_ptr = pbuf;
    for (i = 0; i < len; i++) {
      buf_ptr += sprintf(buf_ptr, " 0x%02X", buf[i]);
    }

    *(buf_ptr) = '\0';
    printf("%s\n", pbuf);
  }
#endif

  task void receive_task () {
    cc2520_metadata_t* meta;

    // Copy the shared transfer buffer to the main thread only rxMsg buffer
    memcpy((uint8_t*) rx_msg_ptr, tsfer_buf, tsfer_buf_len);

    // Save the meta information about the packet
    meta = (cc2520_metadata_t*) tsfer_buf + tsfer_buf_len;
    call PacketMetadata.setLqi(rx_msg_ptr, meta->lqi);
    call PacketMetadata.setRssi(rx_msg_ptr, meta->rssi);

#ifdef CC2520RPI_DEBUG
    {
      uint8_t sam, dam;
      uint8_t* buf = tsfer_buf+5;
      sam = (tsfer_buf[2] >> 6) & 0x3;
      dam = (tsfer_buf[2] >> 2) & 0x3;
      printf("CC2520RpiReceiveP: Received a packet. len: %i\n", tsfer_buf_len);
      printf("    to:   ");
      if (dam == 2) {
        // short address
        print_message(buf, 2);
        buf += 2;
      } else if (dam == 3) {
        print_message(buf, 8);
        buf += 8;
      }
      printf("    from: ");
      if (sam == 2) {
        // short address
        print_message(buf, 2);
      } else if (sam == 3) {
        print_message(buf, 8);
      }
    }
#endif

    // Signal the rest of the stack on the main thread
    rx_msg_ptr = signal BareReceive.receive(rx_msg_ptr);

    pthread_mutex_lock(&mutex_receive);
    pending = FALSE;
    pthread_cond_signal(&cond_pending);
    pthread_mutex_unlock(&mutex_receive);
  }

  void* receive (void *arg) {
    uint8_t buf[256];
    int ret;

#ifdef CC2520RPI_DEBUG
    printf("CC2520RpiReceiveP: Receive thread started.\n");
#endif

    while (1) {
      ret = read(cc2520_file, buf, 128);

      if (ret > 0) {
#ifdef CC2520RPI_DEBUG
//        print_message(buf, ret);
#endif

        pthread_mutex_lock(&mutex_receive);
        while (pending) {
          pthread_cond_wait(&cond_pending, &mutex_receive);
        }

        // Copy the raw packet out of the character device buffer
        memcpy(tsfer_buf, buf, ret);
        tsfer_buf_len = ret;

        pending = TRUE;
        pthread_mutex_unlock(&mutex_receive);

        post receive_task();
      }
    }

    return NULL;
  }

  command error_t SoftwareInit.init () {
    // We pass a buffer back and forth between
    // the upper layers.
    rx_msg_ptr = &rx_msg_buf;

    cc2520_file = open("/dev/radio", O_RDWR);
    if (cc2520_file < 0) {
      fprintf(stderr, "CC2520RpiReceiveP: Could not open radio.\n");
      exit(1);
    }

    // Lock on the transfer buffer that is shared between the main thread and
    // the receive thread
    pthread_mutex_init(&mutex_receive, NULL);
    pthread_cond_init(&cond_pending, NULL);

    // Start a dedicated receiving thread.
    pthread_create(&receive_thread, NULL, &receive, NULL);

    return SUCCESS;
  }
}
