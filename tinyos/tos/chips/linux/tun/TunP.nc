#include <stdio.h>
#include <stdlib.h>
#include <net/if.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <linux/if_tun.h>
#include <linux/ioctl.h>
#include <stdarg.h>

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

    send_info_struct.upper_data = data;
    send_info_struct.link_fragments = 1;
    send_info_struct.link_transmissions = 1;
    send_info_struct.failed = FALSE;

    ret = write(tun_file, out_buf, len + sizeof(struct tun_pi));
    if (ret < 0) {
      send_info_struct.failed = TRUE;
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
    char cmdbuf[4096];
    struct in6_addr addr;

    if (!valid) {
      // The IP address of this node was removed. Remove all addresses
      // from the interface.
      // TODO
    } else {
      char astr[64];

      printf("here\n");

      call IPAddress.getGlobalAddr(&addr);
      inet_ntop6(&addr, astr, 64);

      printf("got address %s\n", astr);

      // Set a route for the prefix the border router is routing through
      // this tun device.
      snprintf(cmdbuf, 4906, "ip -6 route add %s/64 dev %s", astr, tun_name);
      ssystem(cmdbuf);

      // Add the border router's ip address to this tun device
      snprintf(cmdbuf, 4906, "ifconfig %s inet6 add %s/64", tun_name, astr);
      ssystem(cmdbuf);
    }
  }

  command error_t SoftwareInit.init() {
    struct ifreq ifr;
    int err;
    char cmdbuf[4096];

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

    // Setup the IP Addresses
    // ifconfig tun0 up
    snprintf(cmdbuf, 4096, "ifconfig %s up", ifr.ifr_name);
    ssystem(cmdbuf);
    // ifconfig tun0 mtu 1280
    snprintf(cmdbuf, 4906, "ifconfig %s mtu 1280", ifr.ifr_name);
    ssystem(cmdbuf);
    // dummy link-local
    snprintf(cmdbuf, 4906, "ifconfig %s inet6 add fe80::212:aaaa:bbbb:ffff/64",
      ifr.ifr_name);
    ssystem(cmdbuf);

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
