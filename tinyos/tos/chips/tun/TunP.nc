#include <stdio.h>
#include <stdlib.h>
#include <net/if.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <linux/if_tun.h>
#include <linux/ioctl.h>
#include <pthread.h>

#include <stdarg.h>

module TunP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface IPForward;
  }
}

implementation {

  int tun_file;
  pthread_t receive_thread;
  uint8_t in_buf[2048];
  uint8_t out_buf[2048];

  command error_t IPForward.send(struct in6_addr *next_hop,
                                 struct ip6_packet *msg,
                                 void *data) {
    size_t len;
    int ret;

    // skip the frame header
    uint8_t* out_buf_start = out_buf + sizeof(struct tun_pi);

    printf("TUNP: send\n");

    len = iov_len(msg->ip6_data) + sizeof(struct ip6_hdr);

    // copy the header and body into the frame
    memcpy(out_buf_start, &msg->ip6_hdr, sizeof(struct ip6_hdr));
    iov_read(msg->ip6_data, 0, len, out_buf_start + sizeof(struct ip6_hdr));

    ret = write(tun_file, out_buf, len + sizeof(struct tun_pi));
    if (ret < 0) {
      printf("TUNP: send failed\n");
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
    printf("%s\n", cmd);
    fflush(stdout);
    return system(cmd);
  }

  void* receive (void* arg) {
    int len;
    uint8_t buf[2048];

    struct ip6_hdr *iph;
    void *payload;

    printf("receive thread tun\n");

    while (1) {
      len = read(tun_file, buf, 2048);
      printf("got p\n");

      // need to skip over the packet info header from the tun device
      memcpy(in_buf, buf+sizeof(struct tun_pi), len);

      // set up pointers and signal to the next layer
      iph = (struct ip6_hdr*) in_buf;
      payload = (iph + 1);
      signal IPForward.recv(iph, payload, NULL);
    }

    return NULL;
  }

  command error_t SoftwareInit.init() {
    struct ifreq ifr;
    int err;

    tun_file = open("/dev/net/tun", O_RDWR);
    if (tun_file < 0) {
      // error
      printf("no net/tun\n");
    }

    // Clear the ifr struct
    memset(&ifr, 0, sizeof(ifr));

    // Select a TUN device
    ifr.ifr_flags = IFF_TUN;

    // Setup the interface
    err = ioctl(tun_file, TUNSETIFF, (void *) &ifr);
    if (err < 0) {
      printf("bad ioctl\n");
      close(tun_file);
    }

    // Setup the IP Addresses
    // Todo: this should be made nicer somehow (not use ifconfig, be flexible)
    printf("\n");
    ssystem("ifconfig tun0 up");
    ssystem("ifconfig tun0 mtu 1280");
    ssystem("ifconfig tun0 inet6 add 2001:0638:0709:1234::fffe:12/64");
    ssystem("ifconfig tun0 inet6 add fe80::fffe:12/64");
    printf("\n");

    err = pthread_create(&receive_thread, NULL, &receive, NULL);
    if (err) {
      //error
    }


    return SUCCESS;

  }

}

