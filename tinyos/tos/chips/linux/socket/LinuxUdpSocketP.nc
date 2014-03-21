
/* The component provides a linux UDP socket interface. It leverages some
 * Linux-specific features to provide a slightly easier interface.
 *
 * @author: Pat Pannuto <ppannuto@umich.edu>
 */

#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <netdb.h>
#include <errno.h>


generic module LinuxUdpSocketP () {
  provides {
    interface LinuxUdpSocket;
  }
}

implementation {

  int sockfd = -1;
  struct sockaddr_in server;
  struct hostent *hp;

  command error_t LinuxUdpSocket.init (const char* host, uint16_t port) {
    sockfd = socket(PF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
      perror("cannot create socket");
      return FAIL;
    }

    server.sin_family = PF_INET;
    if ( (hp = gethostbyname(host)) == NULL) {
      perror("Invalid or unknown host");
      goto init_fail_sock;
    }

    memcpy(&server.sin_addr.s_addr, hp->h_addr, hp->h_length);

    server.sin_port = htons(port); // Can/should this use magic TOS endian type?

    return SUCCESS;

init_fail_sock:
    close(sockfd);
    sockfd = -1;

    return FAIL;
  }

  command error_t LinuxUdpSocket.close (bool flush_buffer) {
    if (flush_buffer) {
      call LinuxUdpSocket.send_data(NULL, 0);
    }

    if (close(sockfd) < 0) {
      perror("Failed to close socket");
      return FAIL;
    }

    sockfd = -1;
    return SUCCESS;
  }

  command error_t LinuxUdpSocket.build_packet (uint8_t* buf, uint16_t len) {
    uint16_t sent = 0;

    if (sockfd == -1) {
      fprintf(stderr, "LinuxUdpSocket::build_packet\tInvalid sockfd (init not called?\n");
      return FAIL;
    }

    while (sent < len) {
      ssize_t ret;

      ret = sendto(sockfd, buf+sent, len-sent, MSG_MORE,
          (struct sockaddr*) &server, sizeof(server));
      if (ret < 0) {
        perror("Error building UDP packet");
        return FAIL;
      }
      sent += ret;
    }

    return SUCCESS;
  }

  command error_t LinuxUdpSocket.send_data (uint8_t* buf, uint16_t len) {
    if (call LinuxUdpSocket.build_packet(buf, len) == FAIL) {
      return FAIL;
    }

    if (sendto(sockfd, NULL, 0, 0,
          (struct sockaddr*) &server, sizeof(server)) < 0) {
      perror("Error sending UDP packet");
      return FAIL;
    }

    return SUCCESS;
  }
}
