#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>

/* This is the low level receive module that gets packets from the CC2520 kernel
 * module.
 * On init, a receive thread is created that blocks on the character driver.
 * After the receive thread receives a packet, it locks the transfer buffer,
 * copies the packet in and then signals the main thread. The main thread then
 * locks the transfer buffer, copies it into the message_t buffer and signals
 * the upper layers.
 * This seems clumsy to me, and I'm not sure if there is a better way, but it
 * keeps the data in the main thread and should handle packets that arrive
 * in rapid succession.
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

  int ret;
  pthread_t main_thread;
  pthread_t receive_thread;
  pthread_mutex_t mutex_receive;

  message_t* rxMsg;
  message_t rxMsgBuffer;

  uint8_t transfer_buffer[128];

  int cc2520_file;

  // Function that handles the signal when the receive thread is finished
  //  receiving a packet.
  // This function runs in the main thread.
  void receive_done (int sig) {
    cc2520_metadata_t* meta;

    // Request a lock on the transfer buffer
    pthread_mutex_lock(&mutex_receive);

    // Copy the shared transfer buffer to the main thread only rxMsg buffer
    memcpy((uint8_t*) rxMsg, transfer_buffer, (*transfer_buffer)+1);

    // Save the meta information about the packet
    // TODO add these functions
    meta = (cc2520_metadata_t*) transfer_buffer + ((*transfer_buffer)+1);
 //   call PacketMetadata.setLqi(meta->lqi);
 //   call PacketMetadata.setRssi(meta->rssi);
 //   call PacketMetadata.setWasAcked(meta->ack);

    pthread_mutex_unlock(&mutex_receive);

    // Signal the rest of the stack on the main thread
    rxMsg = signal BareReceive.receive(rxMsg);
  }

  void* receive (void* arg) {
    char buf[128];
    char pbuf[2048];
    char *buf_ptr = NULL;
    int i;

    printf("CC2520RpiReceiveP: Receive thread started.\n");

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

        pthread_mutex_lock(&mutex_receive);

        // Copy the raw packet out of the character device buffer
        memcpy(transfer_buffer, buf, ret);

        pthread_mutex_unlock(&mutex_receive);

        // Signal the main thread that a packet is in transfer_buffer
        ret = pthread_kill(main_thread, SIGUSR1);
      }
    }

    return NULL;
  }

  command error_t SoftwareInit.init() {
    // Open the character device for the CC2520
    cc2520_file = open("/dev/radio", O_RDWR);

    rxMsg = &rxMsgBuffer;

    main_thread = pthread_self();

    // Setup the receive_done function to respond to the sigusr1 signal.
    // signal_wrapper is necessary because signal is a keyword in nesc.
    signal_wrapper(SIGUSR1, receive_done);

    // Lock on the transfer buffer that is shared between the main thread and
    //  the receive thread
    ret = pthread_mutex_init(&mutex_receive, NULL);
    if (ret) {
      printf("CC2520RpiReceiveP: mutex creation failed.\n");
      exit(1);
    }

    ret = pthread_create(&receive_thread, NULL, &receive, NULL);
    if (ret) {
      printf("CC2520RpiReceiveP: thread creation failed.\n");
      exit(1);
    }

    return SUCCESS;
  }

}
