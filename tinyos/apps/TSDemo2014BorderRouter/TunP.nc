#include <stdio.h>
#include <stdlib.h>
#include <net/if.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <linux/if_tun.h>
#include <linux/ioctl.h>
#include <stdarg.h>
#include <stddef.h>

#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

#include "file_helpers.h"

#define MAX_IPV6_PACKET_LEN 4096

module TunP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface IPForward;
  }
  uses {
    interface IO;
    interface IPAddress;
    interface TunName;
  }
}

implementation {

#define MAX_TUN_NAME_LEN 100


  int ts_demo_fd;


  struct ifreq6 {
    struct in6_addr addr;
    uint32_t prefix_len;
    unsigned int ifindex;
  };

  int ssystem(const char *fmt, ...);

  int tun_file;
  uint8_t in_buf[MAX_IPV6_PACKET_LEN];
  uint8_t out_buf[MAX_IPV6_PACKET_LEN];

  struct ip6_hdr *iph;
  void *payload;

  // Send related state variables
  struct send_info send_info_struct = {NULL, 1, 1, 1, FALSE, 0};

  // Name of the TUN device in case we need to update it
  char tun_name[MAX_TUN_NAME_LEN];

  task void sendDone_task() {
    signal IPForward.sendDone(&send_info_struct);
  }

  command error_t IPForward.send (struct in6_addr *next_hop,
                                  struct ip6_packet *msg,
                                  void *data) {
    size_t len;
    int ret;

    // skip the frame header
    uint8_t* out_buf_start = out_buf;

    TUN_PRINTF("Sending outgoing packet to TUN interface.\n");

    len = iov_len(msg->ip6_data) + sizeof(struct ip6_hdr);

    // copy the header and body into the frame
    memcpy(out_buf_start, &msg->ip6_hdr, sizeof(struct ip6_hdr));
    iov_read(msg->ip6_data, 0, len, out_buf_start + sizeof(struct ip6_hdr));


// DEMO TS 2014
    if (ts_demo_fd < 1) {
      ts_demo_fd = open("/tmp/lowpan_fifo", O_WRONLY|O_NONBLOCK);
    }
    if (ts_demo_fd > 1) {
      if (write(ts_demo_fd, out_buf_start, len + sizeof(struct tun_pi)) == -1) {
        ts_demo_fd = -1;
      }
    }


    send_info_struct.upper_data = data;
    send_info_struct.link_fragments = 1;
    send_info_struct.link_transmissions = 1;
    send_info_struct.failed = FALSE;

    ret = write(tun_file, out_buf, len + sizeof(struct tun_pi));
    if (ret < 0) {
      printf("annoyed\n");
      send_info_struct.failed = TRUE;
      perror("tun write");
      ERROR("Sending packet to TUN failed.\n");
      ERROR("%s\n", strerror(errno));
      return FAIL;
    }

    post sendDone_task();
    return SUCCESS;
  }

  // This tasked is posted when a packet comes in.
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
      return;
    } else if (len == -1) {
      switch (errno) {
        case EAGAIN:
          // select fired incorrectly
          return;
        default:
          ERROR("Reading from tun caused errors.\n");
          ERROR("errno: %i\n", errno);
          exit(1);
      }
    }

    TUN_PRINTF("Successfully got a packet from the TUN interface.\n");

    memcpy(in_buf, buf, len);

    post receive_task();
  }

  event void IPAddress.changed (bool valid) {
    struct ifreq ifr;
    struct ifreq6 ifr6;
    char cmdbuf[4096];
    int sockfd;
    int err;

    if (!valid) {
      // The IP address of this node was removed. Remove all addresses
      // from the interface.
      // TODO
    } else {
      char astr[64];

      call IPAddress.getGlobalAddr(&ifr6.addr);
      inet_ntop6(&ifr6.addr, astr, 64);

      // Set a route for the prefix the border router is routing through
      // this tun device.
      snprintf(cmdbuf, 4906, "ip -6 route add %s/64 dev %s", astr, tun_name);
      ssystem(cmdbuf);

      // Get a socket to perform the ioctls on
      sockfd = socket(AF_INET6, SOCK_DGRAM, 0);

      // Get the ifr_index
      strncpy(ifr.ifr_name, tun_name, IFNAMSIZ);
      err = ioctl(sockfd, SIOCGIFINDEX, &ifr);
      if (err < 0) {
        ERROR("ioctl could not get ifindex.\n");
        close(tun_file);
        exit(1);
      }

      // Add the border router's ip address to this tun device
      ifr6.prefix_len = 128;
      ifr6.ifindex = ifr.ifr_ifindex;
      err = ioctl(sockfd, SIOCSIFADDR, &ifr6);
      if (err < 0) {
        ERROR("ioctl could not set the border routers address.\n");
      }

      close(sockfd);
    }
  }

  command error_t SoftwareInit.init() {
    struct ifreq ifr;
    struct ifreq6 ifr6;
    int err;
    char cmdbuf[4096];
    int sockfd;

    tun_file = open("/dev/net/tun", O_RDWR);
    if (tun_file < 0) {
      // error
      ERROR("Could not create a tun interface. errno: %i\n", errno);
      ERROR("%s\n", strerror(errno));
      exit(1);
    }

    // Clear the ifr struct
    memset(&ifr, 0, sizeof(ifr));

    // Set the TUN name
    strncpy(ifr.ifr_name, call TunName.getTunName(), IFNAMSIZ);

    // Select a TUN device
    ifr.ifr_flags = IFF_TUN | IFF_NO_PI;

    // Setup the interface
    err = ioctl(tun_file, TUNSETIFF, (void *) &ifr);
    if (err < 0) {
      ERROR("ioctl could not set up tun interface\n");
      close(tun_file);
      exit(1);
    }

    // Make nonblocking in case select() gives us trouble
    make_nonblocking(tun_file);

    // Save the name of the tun interface
    strncpy(tun_name, ifr.ifr_name, MAX_TUN_NAME_LEN);

    // Get a socket to perform the ioctls on
    sockfd = socket(AF_INET6, SOCK_DGRAM, 0);

    // Set the interface to be up
    // ifconfig tun0 up
    err = ioctl(sockfd, SIOCGIFFLAGS, &ifr);
    if (err < 0) {
      ERROR("ioctl could not get flags.\n");
      close(tun_file);
      exit(1);
    }
    ifr.ifr_flags |= IFF_UP | IFF_RUNNING;
    err = ioctl(sockfd, SIOCSIFFLAGS, &ifr);
    if (err < 0) {
      ERROR("ioctl could not bring up the TUN network interface.\n");
      perror("tup up");
      ERROR("errno: %i\n", errno);
      close(tun_file);
      exit(1);
    }

    // Set the MTU of the interface
    // ifconfig tun0 mtu 1280
    ifr.ifr_mtu = 1280;
    err = ioctl(sockfd, SIOCSIFMTU, &ifr);
    if (err < 0) {
      ERROR("ioctl could not set the MTU of the TUN network interface.\n");
      close(tun_file);
      exit(1);
    }

    // Get the ifr_index
    err = ioctl(sockfd, SIOCGIFINDEX, &ifr);
    if (err < 0) {
      ERROR("ioctl could not get ifindex.\n");
      close(tun_file);
      exit(1);
    }

    // Set a dummy link-local address on the interface
    // ifconfig tun0 inet6 add fe80::212:aaaa:bbbb:ffff/64
    inet_pton6("fe80::212:aaaa:bbbb:ffff", &ifr6.addr);
    ifr6.prefix_len = 64;
    ifr6.ifindex = ifr.ifr_ifindex;
    err = ioctl(sockfd, SIOCSIFADDR, &ifr6);
    if (err < 0) {
      ERROR("ioctl could not set link-local address TUN network interface.\n");
      close(tun_file);
      exit(1);
    }

    close(sockfd);

    // Register the file descriptor with the IO manager that will call select()
    call IO.registerFileDescriptor(tun_file);


// FOR TS DEMO 2014
{
    mkfifo("/tmp/lowpan_fifo", 0666);
    __nesc_keyword_signal(SIGPIPE, SIG_IGN);
}






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
