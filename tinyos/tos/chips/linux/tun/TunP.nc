#include <stdio.h>
#include <stdlib.h>
#include <net/if.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <linux/if_tun.h>
#include <linux/ioctl.h>

#include <stdarg.h>

#define MAX_IPV6_PACKET_LEN 2048

module TunP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface IPForward;
  }
  uses {
    interface IO;
  }
}

implementation {

  int ssystem(const char *fmt, ...);

  int tun_file;
  pthread_t receive_thread;
  uint8_t in_buf[MAX_IPV6_PACKET_LEN];
  uint8_t out_buf[MAX_IPV6_PACKET_LEN];

  struct ip6_hdr *iph;
  void *payload;

  // Send related state variables
  struct send_info send_info_struct = {NULL, 1, 1, 1, FALSE, 0};

  // Makes the given file descriptor non-blocking.
  // Returns 1 on success, 0 on failure.
  int make_nonblocking (int fd) {
    int flags, ret;

    flags = fcntl(fd, F_GETFL, 0);
    if (flags == -1) {
      return 0;
    }
    // Set the nonblocking flag.
    flags |= O_NONBLOCK;
    ret = fcntl(fd, F_SETFL, flags);
    
    return ret != -1;
  }

  task void sendDone_task() {
    signal IPForward.sendDone(&send_info_struct);
  }

  // todo: add timer and sendDone
  command error_t IPForward.send (struct in6_addr *next_hop,
                                  struct ip6_packet *msg,
                                  void *data) {
    size_t len;
    int ret;

    // skip the frame header
    uint8_t* out_buf_start = out_buf;

    TUN_PRINTF("send to interface\n");

    len = iov_len(msg->ip6_data) + sizeof(struct ip6_hdr);

    // copy the header and body into the frame
    memcpy(out_buf_start, &msg->ip6_hdr, sizeof(struct ip6_hdr));
    iov_read(msg->ip6_data, 0, len, out_buf_start + sizeof(struct ip6_hdr));

    send_info_struct.upper_data = data;
    send_info_struct.link_fragments = 1;
    send_info_struct.link_transmissions = 1;
    send_info_struct.failed = FALSE;

    ret = write(tun_file, out_buf, len + sizeof(struct tun_pi));
    if (ret < 0) {
      send_info_struct.failed = TRUE;
      TUN_PRINTF("send failed\n");
    }

    post sendDone_task();
    return SUCCESS;
  }

  task void receive_task () {
    // set up pointers and signal to the next layer
    iph = (struct ip6_hdr*) in_buf;
    payload = (iph + 1);
    signal IPForward.recv(iph, payload, NULL);
  }



  // There is a packet waiting on the tun interface. Read() it and post to
  // signal upper layers.
  async event void IO.receiveReady () {
    int len;
    uint8_t buf[MAX_IPV6_PACKET_LEN];

    len = read(tun_file, buf, MAX_IPV6_PACKET_LEN);
    if (len == 0) {
      // spurious wakeup from select()
      return;
    } else if (len == -1) {
      ERROR("Reading from tun caused errors.\n");
      ERROR("errno: %i\n", errno);
      exit(1);
    }
    TUN_PRINTF("got packet\n");

    memcpy(in_buf, buf, len);

    post receive_task();
  }

  command error_t SoftwareInit.init() {
    struct ifreq ifr;
    int err;

    tun_file = open("/dev/net/tun", O_RDWR);
    if (tun_file < 0) {
      // error
      ERROR("Could not create a tun interface.\n");
      exit(1);
    }

    // Clear the ifr struct
    memset(&ifr, 0, sizeof(ifr));

    // Select a TUN device
    ifr.ifr_flags = IFF_TUN | IFF_NO_PI;

    // Setup the interface
    err = ioctl(tun_file, TUNSETIFF, (void *) &ifr);
    if (err < 0) {
      ERROR("ioctl could not set up tun interface\n");
      close(tun_file);
    }

    // Make nonblocking in case select() gives us trouble
    make_nonblocking(tun_file);

    // Setup the IP Addresses
    // Todo: this should be made nicer somehow (not use ifconfig, be flexible)
    ssystem("ifconfig tun0 up");
    ssystem("ifconfig tun0 mtu 1280");
    ssystem("ip -6 route add 2001:470:1f11:131a::/64 dev tun0");
    // Dummy link local addr to make the dhcp server work
    ssystem("ifconfig tun0 inet6 add fe80::212:aaaa:bbbb:ffff/64");

    // Register the file descriptor with the IO manager that will call select()
    call IO.registerFileDescriptor(tun_file);

    return SUCCESS;
  }

  // Runs a command on the local system using
  // the kernel command interpreter.
  int ssystem(const char *fmt, ...) {
    char cmd[128];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(cmd, sizeof(cmd), fmt, ap);
    va_end(ap);
    TUN_PRINTF("%s\n", cmd);
    return system(cmd);
  }
}

