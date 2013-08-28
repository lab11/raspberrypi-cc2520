#include <unistd.h>
#include <stdio.h>
#include <sys/prctl.h>

#include "file_helpers.h"


#define PACKET_BUFFER_LEN 256

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
    interface IO;
    interface UnixTime;
  }
}

implementation {

  int cc2520_pipe;

  uint8_t* rx_msg_ptr;
  message_t rx_msg_buf;

  int read_pipe[2];

#ifdef CC2520RPI_DEBUG
  void print_message (uint8_t* buf, uint8_t len) {
    char pbuf[2048];
    char *buf_ptr = NULL;
    int i;

    buf_ptr = pbuf;
    for (i = 0; i < len; i++) {
      buf_ptr += sprintf(buf_ptr, "%02x", buf[i]);
    }

    *(buf_ptr) = '\0';
    printf("%s\n", pbuf);
  }
#endif

  task void receive_task () {
    uint8_t rssi, crc_lqi;

    // Save the meta information about the packet
    rssi    = rx_msg_ptr[rx_msg_ptr[0] - 1];
    crc_lqi = rx_msg_ptr[rx_msg_ptr[0]];
    if ((crc_lqi >> 7) == 0) {
      RADIO_PRINTF("CRC failed. rssi: %x crc: %x lqi: %x\n",
        rssi, (crc_lqi >> 7), crc_lqi & 0x7F);
      return;
    }
    call PacketMetadata.setLqi((message_t*) rx_msg_ptr, crc_lqi & 0x7F);
    call PacketMetadata.setRssi((message_t*) rx_msg_ptr, rssi);

    // Set the timestamp of when the packet was received
    call PacketMetadata.setTimestamp((message_t*) rx_msg_ptr,
                                     call UnixTime.getMicroseconds());

#ifdef CC2520RPI_DEBUG
    {
      uint8_t sam, dam;
      uint8_t* buf = rx_msg_ptr+6;
      sam = (rx_msg_ptr[2] >> 6) & 0x3;
      dam = (rx_msg_ptr[2] >> 2) & 0x3;
      RADIO_PRINTF("Received a packet. len: %i\n", rx_msg_ptr[0]+1);
      print_message(rx_msg_ptr, rx_msg_ptr[0]-1);
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
    atomic rx_msg_ptr = (uint8_t*)
                        signal BareReceive.receive((message_t*) rx_msg_ptr);
  }

  async event void IO.receiveReady () {
    ssize_t ret;

    // read 1 byte in from the fifo
    // this should be the length
    ret = read(cc2520_pipe, rx_msg_ptr, 1);
    if (ret == 0) {
      // Didn't get any data
      RADIO_PRINTF("Read 0 bytes from pipe.\n");
      return;

    } else if (ret == -1) {
      switch (errno) {
        case EAGAIN:
          // This appears to be a spurious call from select() that shouldn't
          // really happen but does. Because this fd is nonblocking, the read()
          // returned with -1 and we should just go back to sleeping.
          // If there is really data here, select() will trigger this again.
          RADIO_PRINTF("spurious select wakeup.\n");
          return;
        default:
          ERROR("Error reading length from cc2520. errno: %i\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
      }
    }

    // Read the rest of the packet from the fifo
    ret = read(cc2520_pipe, rx_msg_ptr+1, rx_msg_ptr[0]);
    if (ret == -1) {
      ERROR("Error reading packet from cc2520. errno: %i\n", errno);
      ERROR("%s", strerror(errno));
      exit(1);
    } else if (ret != rx_msg_ptr[0]) {
      // Didn't get a full packet. Let's just drop it and hope for good things
      // in the future.
      return;
    }

    post receive_task();
  }

  command error_t SoftwareInit.init () {
    // We pass a buffer back and forth between
    // the upper layers.
    int cc2520_file;
    int ret;

    rx_msg_ptr = (uint8_t*) &rx_msg_buf;

    cc2520_file = open("/dev/radio", O_RDWR);
    if (cc2520_file < 0) {
      ERROR("Could not open radio.\n");
      exit(1);
    }

    // create a pipe to buffer the input
    ret = pipe(read_pipe);
    if (ret == -1) {
      ERROR("Could not create pipe.\n");
      exit(1);
    }

    // Create a very simple process that just reads in from the cc2520 driver
    //  and puts the data in the pipe.
    if (!fork()) {
      // CHILD
      uint8_t pkt_buf[PACKET_BUFFER_LEN];
      close(read_pipe[0]);

      {
        // Name the child process
        const char RX_STR[] = "-2520-Rx";
        char proc_name[17] = {0};
        prctl(PR_GET_NAME, proc_name, 0, 0, 0);
        if (strlen(proc_name) > (16 - strlen(RX_STR))) {
          strcpy(proc_name + 16 - strlen(RX_STR), RX_STR);
        } else {
          strcat(proc_name, RX_STR);
        }
        prctl(PR_SET_NAME, proc_name, 0, 0, 0);

        RADIO_PRINTF("Spawned RX Process (%d). TOS Process (%d)\n",
            getpid(), getppid());
      }

      // Tell kernel to deliver signal when parent dies.
      ret = prctl(PR_SET_PDEATHSIG, SIGKILL);
      if (ret == -1) {
        ERROR("Error setting signal when the parent dies.\n");
        ERROR("%s\n", strerror(errno));
      }

      while(1) {
        ssize_t len;
        len = read(cc2520_file, pkt_buf, PACKET_BUFFER_LEN);
        if (len <= 0) {
          ERROR("Pipe died.\n");
          close(read_pipe[1]);
        }
        write(read_pipe[1], pkt_buf, len);
      }
    }

    // PARENT
    close(read_pipe[1]);
    close(cc2520_file);

    cc2520_pipe = read_pipe[0];

    // Make the pipe non blocking just in case we get a spurious select() call
    make_nonblocking(cc2520_pipe);

    // Add the cc2520 pipe end to the select call
    call IO.registerFileDescriptor(cc2520_pipe);

    RADIO_PRINTF("registered receiver.\n");

    return SUCCESS;
  }
}
