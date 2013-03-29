#include <sys/prctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/epoll.h>
#include <errno.h>


module Bcm2835InterruptP {
  provides {
    interface Init as SoftwareInit @exactlyonce();

/*
    provides interface Bcm2835Interrupt as Port1_03; // GPIO 2
    provides interface Bcm2835Interrupt as Port1_05; // GPIO 3
    provides interface Bcm2835Interrupt as Port1_07; // GPIO 4
    provides interface Bcm2835Interrupt as Port1_08; // GPIO 14
  */  interface GpioInterrupt as Port1_10; // GPIO 15
  /*  provides interface Bcm2835Interrupt as Port1_11; // GPIO 17
    provides interface Bcm2835Interrupt as Port1_12; // GPIO 18
    provides interface Bcm2835Interrupt as Port1_13; // GPIO 27
    provides interface Bcm2835Interrupt as Port1_15; // GPIO 22
    provides interface Bcm2835Interrupt as Port1_16; // GPIO 23
    provides interface Bcm2835Interrupt as Port1_18; // GPIO 24
    provides interface Bcm2835Interrupt as Port1_19; // GPIO 10
    provides interface Bcm2835Interrupt as Port1_21; // GPIO 9
    provides interface Bcm2835Interrupt as Port1_22; // GPIO 25
    provides interface Bcm2835Interrupt as Port1_23; // GPIO 11
    provides interface Bcm2835Interrupt as Port1_24; // GPIO 8
    provides interface Bcm2835Interrupt as Port1_26; // GPIO 7
    */
  }
}

implementation {

#define NUMBER_OF_INTERRUPT_PINS 10

  typedef enum {
    INTERRUPT_NONE,
    INTERRUPT_RISING,
    INTERRUPT_FALLING,
  } setting_e;

  typedef struct {
    uint8_t   pin_number; // bcm2835 pin number to change
    setting_e setting;
  } interrupt_setting_t;

  uint8_t pins[NUMBER_OF_INTERRUPT_PINS] = {2, 7, 8, 9, 10, 11, 14, 15, 18, 27};
  char* pin_names[NUMBER_OF_INTERRUPT_PINS]= {"2", "7", "8", "9", "10", "11",
                                              "14", "15", "18", "27"};
  int gpio_edge_fds[NUMBER_OF_INTERRUPT_PINS];
  int gpio_value_fds[NUMBER_OF_INTERRUPT_PINS];

  struct epoll_event ev_int[NUMBER_OF_INTERRUPT_PINS];

  const char* setting_str[] = {"none", "rising", "falling"};

  int int_settings_pipe;
  int write_pipe[2];

 // read_fifo_header_t send_hdr;


  // Callback for the alarm
  void InterruptSignal (int sig, siginfo_t* siginfo, void* a) {
    signal Port1_10.fired();
  }

  int get_pin_index (int pin_number) {
    int i;
    for (i=0; i<NUMBER_OF_INTERRUPT_PINS; i++) {
      if (pins[i] == pin_number) {
        return i;
      }
    }
    return -1;
  }


  // Makes the given file descriptor non-blocking.
  // Returns 1 on success, 0 on failure.
 /* int make_nonblocking (int fd) {
    int flags, ret;

    flags = fcntl(fd, F_GETFL, 0);
    if (flags == -1) {
      return 0;
    }
    // Set the nonblocking flag.
    flags |= O_NONBLOCK;
    ret = fcntl(fd, F_SETFL, flags);

    return ret != -1;
  }*/
/*
  task void sendDone_task() {

    switch (send_hdr.ret) {
      case CC2520_TX_BUSY:
      case CC2520_TX_ACK_TIMEOUT:
      case CC2520_TX_FAILED:
        call PacketMetadata.setWasAcked(send_hdr.ptr_to_msg, FALSE);
        break;
      case CC2520_TX_LENGTH:
        ERROR("INCORRECT LENGTH\n");
        break;
      case CC2520_TX_SUCCESS:
        call PacketMetadata.setWasAcked(send_hdr.ptr_to_msg, TRUE);
        break;
      default:
        if (send_hdr.ret == send_hdr.len - 1) {
          call PacketMetadata.setWasAcked(send_hdr.ptr_to_msg, TRUE);
        } else {
          ERROR("write() weird return code: %i\n", send_hdr.ret);
        }
        break;
    }

    signal BareSend.sendDone(send_hdr.ptr_to_msg, SUCCESS);
  }
*/
  command error_t SoftwareInit.init() {
    int ret;

    // Create a pipe to send interrupt setting information to the interrupt
    // managing process
    ret = pipe(write_pipe);
    if (ret == -1) {
      ERROR("Could not create write pipe.\n");
      exit(1);
    }

    // Create a process that pulls interrupt config info from a pipe and watches
    // for any interrups. When one is found it signals the main process.
    if (!fork()) {
      // CHILD
      int i;
      int export_fd;
      char filename[50];

      struct epoll_event ev_pipe;
      int epoll_fd;

      close(write_pipe[1]);

      {
        // Name the process
        const char RX_STR[] = "-Interrupt";
        char proc_name[17] = {0};
        prctl(PR_GET_NAME, proc_name, 0, 0, 0);
        if (strlen(proc_name) > (16 - strlen(RX_STR))) {
          strcpy(proc_name + 16 - strlen(RX_STR), RX_STR);
        } else {
          strcat(proc_name, RX_STR);
        }
        prctl(PR_SET_NAME, proc_name, 0, 0, 0);

        RADIO_PRINTF("Spawned Interrupt Process (%d). TOS Process (%d)\n",
            getpid(), getppid());
      }

      // Tell kernel to deliver signal when parent dies.
      prctl(PR_SET_PDEATHSIG, SIGKILL);

      // Initialize all of the interrupt files
      // open the export file we need to write to
      export_fd = open("/sys/class/gpio/export", O_WRONLY);
      if (export_fd == -1) {
        ERROR("Could not open export file. errno: %i\n", errno);
        ERROR("%s\n", strerror(errno));
        exit(1);
      }

      // Go through and check if all gpio "files" have been created
      // Set all interrupts to none
      for (i=0; i<NUMBER_OF_INTERRUPT_PINS; i++) {
        uint8_t temp_buf[5];

        sprintf(filename, "/sys/class/gpio/gpio%i", pins[i]);
        if (access(filename, F_OK) == -1) {
          // write to export to open gpio file
          //ret = write(export_fd, &(pins[i]), 2);
          INT_PRINTF("trying to write %s\n", pin_names[i]);
          ret = write(export_fd, pin_names[i], strlen(pin_names[i]));
          if (ret == -1) {
            switch (errno) {
              case EBUSY:
                ERROR("Could not write %s to export.\n", pin_names[i]);
                continue;
                break;
              default:
                ERROR("Could not write to export. errno: %i\n", errno);
                ERROR("%s\n", strerror(errno));
                exit(1);
            }
          }
        } else {
          INT_PRINTF("Successfully found %s.\n", filename);
        }

        // Turn interrupt off
        sprintf(filename, "/sys/class/gpio/gpio%i/edge", pins[i]);
        gpio_edge_fds[i] = open(filename, O_WRONLY);
        if (gpio_edge_fds[i] == -1) {
          ERROR("Could not open file to set interrupt. errno: %i\n", errno);
          ERROR("Filename: %s\n", filename);
          ERROR("%s\n", strerror(errno));
          exit(1);
        }
        ret = write(gpio_edge_fds[i],
                    setting_str[INTERRUPT_NONE],
                    strlen(setting_str[INTERRUPT_NONE]));
        if (ret == -1) {
          ERROR("Could not write to int edge. errno: %i\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
        } else {
          INT_PRINTF("Disabled interrupt for pin %s\n", pin_names[i]);
        }

        // Open all of the value file descriptors for each interrupt pin
        sprintf(filename, "/sys/class/gpio/gpio%i/value", pins[i]);
        gpio_value_fds[i] = open(filename, O_RDWR);
        if (gpio_value_fds[i] == -1) {
          ERROR("Could not open file to read interrupt. errno: %i\n",
                pins[i], errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
        }
        // Do an initial read to prevent a spurious interrupt
        ret = read(gpio_value_fds[i], temp_buf, 5);
        if (ret == -1) {
          ERROR("Could not read val from pin %i. errno: %i\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
        }
        lseek(gpio_value_fds[i], 0, SEEK_SET);
      }

      // Create an epoll event notifier to watch for interrupts and config
      // messages from the pipe.
      epoll_fd = epoll_create(1);
      if (epoll_fd == -1) {
        ERROR("Could not create an epoll. errno: %i\n", errno);
        ERROR("%s\n", strerror(errno));
        exit(1);
      }

      // Set up the event as a read
      ev_pipe.events = EPOLLIN;
      ev_pipe.data.fd = write_pipe[0];

      // Attach the pipe file descriptor to it
      ret = epoll_ctl(epoll_fd, EPOLL_CTL_ADD, write_pipe[0], &ev_pipe);
      if (ret == -1) {
        ERROR("Could not add write pipe to epoll. errno: %i\n", errno);
        ERROR("%s\n", strerror(errno));
        exit(1);
      }

      while(1) {
        ssize_t len, ret_val;

        int number_fds;
        struct epoll_event ready_event;

        // Wait indefinitely for something to be ready.
        //INT_PRINTF("Wait for some file activity...\n");
        number_fds = epoll_wait(epoll_fd, &ready_event, 1, -1);
        if (number_fds == -1) {
          ERROR("Epoll wait returned an error. errno: %i\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
        }

        for (i=0; i<number_fds; i++) {

          if (ready_event.data.fd == write_pipe[0]) {
            // Got config information from the pipe
            interrupt_setting_t iset;
            int pin_index;

            // handle new data from the pipe
            ret = read(write_pipe[0], &iset, sizeof(interrupt_setting_t));
            if (ret == -1) {
              ERROR("Failure reading config from pipe. errno: %i\n", errno);
              ERROR("%s\n", strerror(errno));
              exit(1);
            }

            // Can now figure out where this pin fits into all of our arrays
            pin_index = get_pin_index(iset.pin_number);

            // Write to the proper gpio file the new interrupt setting
            ret = write(gpio_edge_fds[pin_index],
                        setting_str[iset.setting],
                        strlen(setting_str[iset.setting]));
            if (ret == -1) {
              ERROR("Could not write to int %i edge. errno: %i\n",
                    iset.pin_number, errno);
              ERROR("%s\n", strerror(errno));
            } else {
              INT_PRINTF("Set interrupt to %s for pin %i\n",
                         setting_str[iset.setting], iset.pin_number);
            }

            // Reconfigure epoll
            switch (iset.setting) {
              case INTERRUPT_NONE:
                // Remove the file from epoll
                ret = epoll_ctl(epoll_fd,
                                EPOLL_CTL_DEL,
                                gpio_value_fds[pin_index],
                                NULL);
                if (ret == -1) {
                  switch (errno) {
                    case ENOENT:
                      INT_PRINTF("Tried to remove fd from epoll that wasn't \
                                  there. It must have already been none.\n");
                      break;
                    default:
                      ERROR("Could not add write pipe to epoll. errno: %i\n", errno);
                      ERROR("%s\n", strerror(errno));
                      exit(1);
                  }
                }
                break;

              case INTERRUPT_RISING:
              case INTERRUPT_FALLING:
                // Set epoll to trigger on an interrupt
                ev_int[pin_index].events = EPOLLPRI;
                ev_int[pin_index].data.fd = gpio_value_fds[pin_index];

                // Attach the pipe file descriptor to it
                ret = epoll_ctl(epoll_fd,
                                EPOLL_CTL_ADD,
                                gpio_value_fds[pin_index],
                                &ev_int[pin_index]);
                if (ret == -1) {
                  ERROR("Could not add pin %i to epoll. errno: %i\n",
                        iset.pin_number, errno);
                  ERROR("%s\n", strerror(errno));
                  exit(1);
                } else {
                  INT_PRINTF("Successfully added pin %i to the epoll.\n",
                             iset.pin_number);
                }
                break;

              default:
                break;
            }




          } else {
            // Some interrupt triggered
            int interrupt_fd;
            int pin_index = -1;
            int j;
            uint8_t int_val_buf[5];
            memset(int_val_buf, 0, 5);

            // !!!TODO: optimize this
            for (j=0; j<NUMBER_OF_INTERRUPT_PINS; j++) {
              if (ready_event.data.fd == gpio_value_fds[j]) {
                pin_index = j;
                break;
              }
            }

            // Read the data from the file so it doesn't retrigger epoll
            ret = read(ready_event.data.fd, int_val_buf, 4);
            if (ret == -1) {
              ERROR("Failure reading from pin %i value. errno: %i\n",
                    pin_index, errno);
              ERROR("%s\n", strerror(errno));
              exit(1);
            } else {
              int_val_buf[1] = '\0';
              INT_PRINTF("Read value: %s from pin %i\n",
                         int_val_buf, pins[pin_index]);
            }
            lseek(ready_event.data.fd, 0, SEEK_SET);

          }
        }

      }





/*


        len = read(write_pipe[0], &iset, sizeof(interrupt_setting_t));
        if (len == -1) {
          ERROR("Pipe error: %i.\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
        }

        sprintf(filename, "/sys/class/gpio/gpio%i/edge", iset.pin_number);
        gpio_edge_fd = open(filename, O_WR);
        if (gpio_edge_fd == -1) {
          ERROR("Could not open file to set interrupt. errno: %i", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
        }
        ret = write(gpio_edge_fd,
                    &(setting_str[iset.setting]),
                    strlen(setting_str[iset.settingq]));
        if (ret == -1) {
          ERROR("Coild not write to int edge. errno: %i\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
        }
        close(gpio_edge_fd);

        // Set the length byte from the whdr
        pkt_buf[0] = whdr.len;
        // Read the actual packet
        // The remainder of the packet will be the length byte minus the two
        // crc bytes.
        len = read(write_pipe[0], pkt_buf + 1, whdr.len-2);
        if (len <= 0) {
          ERROR("Error reading from pipe.\n");
          close(read_pipe[1]);
          close(write_pipe[0]);
        }

        // When writing to the cc2520 driver, the length is the length byte
        // plus 1 (for itself) minux the 2 byte crc
        ret_val = write(cc2520_file, pkt_buf, whdr.len-1);

        // write the return code to the read fifo
        rhdr.ptr_to_msg = whdr.ptr_to_msg;
        rhdr.ret = ret_val;
        rhdr.len = whdr.len;
        ret_val = write(read_pipe[1], &rhdr, sizeof(read_fifo_header_t));
        if (ret_val == -1) {
          ERROR("Error writing to read pipe.\n");
        } else if (ret_val != sizeof(read_fifo_header_t)) {
          ERROR("Return code was not fully written to the pipe\n");
          ERROR("Only %i bytes were written\n", ret_val);
        }
      }
      */
    }

    // PARENT
    close(write_pipe[0]);

    int_settings_pipe = write_pipe[1];

    return SUCCESS;
  }


  async command error_t Port1_10.enableRisingEdge() {
    int ret;
    interrupt_setting_t iset;

    iset.pin_number = 15;
    iset.setting = INTERRUPT_RISING;

    ret = write(int_settings_pipe, &iset, sizeof(interrupt_setting_t));

    return SUCCESS;
  }

  async command error_t Port1_10.enableFallingEdge() {
    int ret;
    interrupt_setting_t iset;

    iset.pin_number = 15;
    iset.setting = INTERRUPT_FALLING;

    ret = write(int_settings_pipe, &iset, sizeof(interrupt_setting_t));

    return SUCCESS;

  }
  async command error_t Port1_10.disable() {

  }




/*
  // Read from read_fifo to get send metadata for the last sent packet
  async event void IO.receiveReady () {
    ssize_t ret;

    RADIO_PRINTF("send receive ready.\n");

    ret = read(cc2520_read, &send_hdr, sizeof(read_fifo_header_t));
    if (ret == -1) {
      switch (errno) {
        case EAGAIN:
          // This appears to be a spurious call from select() that shouldn't
          // really happen but does. Because this fd is nonblocking, the read()
          // returned with -1 and we should just go back to sleeping.
          // If there is really data here, select() will trigger this again.
          RADIO_PRINTF("spurious select wakeup.\n");
          return;
        default:
          ERROR("Error with packet result fifo. errno: %i\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
      }
    } else if (ret != sizeof(read_fifo_header_t)) {
      // Not sure what happened here. This is definitely an error somewhere.
      ERROR("Read only %i bytes from the packet result fifo\n", ret);

      // Don't signal the sendDone() task with invalid information. I'm not sure
      // how this will affect certain applications, but hopefully this case
      // doesn't happen.
      return;
    }

    // Post a task to trigger sendDone so we can get out of the async
    post sendDone_task();
  }
*/

  /*
  command error_t BareSend.send (message_t* msg) {
    write_fifo_header_t whdr;
    ssize_t ret;

#ifdef CC2520RPI_DEBUG
    {
      uint8_t sam, dam;
      uint8_t* buf = (uint8_t*) msg;
      sam = (buf[2] >> 6) & 0x3;
      dam = (buf[2] >> 2) & 0x3;
      RADIO_PRINTF("Sending a packet. len: %i\n", buf[0]+1);
      buf += 6;
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

    whdr.ptr_to_msg = msg;
    whdr.len = ((uint8_t*) msg)[0];
    ret = write(cc2520_write, &whdr, sizeof(write_fifo_header_t));
    if (ret == -1) {
      ERROR("could not write to fifo.\n");
    }

    // write the rest of the packet to the fifo
    // Write() the body of the packet (no length byte or 2 byte crc)
    ret = write(cc2520_write, ((uint8_t*)msg)+1, whdr.len-2);
    if (ret == -1) {
      ERROR("could not write to fifo.\n");
    }

    RADIO_PRINTF("send packet.\n");

    return SUCCESS;
  }

  command error_t BareSend.cancel (message_t* msg) {
    return FAIL;
  }
  */
}
