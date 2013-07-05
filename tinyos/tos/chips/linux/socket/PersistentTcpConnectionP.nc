
/* The component provides a linux TCP socket that will automatically reconnect
 * if the socket is closed for some reason.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
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


generic module PersistentTcpConnectionP () {
  uses {
    interface IO;
    interface Timer<TMilli> as ReconnectTimer;
  }
  provides {
    interface TcpSocket;
  }
}

implementation {

#define INBUF_SIZE 4096
#define HOST_SIZE 512

#define RECONNECT_PERIOD 1000

  char remote_host[HOST_SIZE];
  uint16_t remote_port;

  int sock = -1;

  uint8_t inbuf[INBUF_SIZE];

  uint8_t msg[INBUF_SIZE];
  ssize_t msglen;

  // This helper function tries to reconnect, and if that fails starts a
  // callback timer to try periodically.
  void reconnect_helper () {
    error_t result;
    result = call TcpSocket.connect(remote_host, remote_port);
    if (result != SUCCESS) {
      atomic sock = -1;
      // Could not reconnect the socket to the remote host.
      // Try again later.
      call ReconnectTimer.startOneShot(RECONNECT_PERIOD);
    }
  }

  // This is called when a send or receive detects that the socket has been
  // closed. This will reset the socket and try to reconnect to the server.
  void reconnect () {
    if (sock == -1) return;

    // Remove the old socket from the select call
    call IO.unregisterFileDescriptor(sock);
    atomic sock = -1;

    reconnect_helper();
  }

  // Try to reconnect the socket again
  event void ReconnectTimer.fired () {
    reconnect_helper();
  }

  command error_t TcpSocket.connect (const char* host, uint16_t port) {
    struct addrinfo hints;
    struct addrinfo *strmSvr;
    char port_str[6];
    int error;

    // Save the desired host in case a reconnect is necessary
    strncpy(remote_host, host, HOST_SIZE);
    remote_port = port;

    // Tell getaddrinfo() that we only want a TCP connection
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_socktype = SOCK_STREAM;

    // Convert port number to a string
    snprintf(port_str, 6, "%d", port);

    // Resolve the HOST to an IP address
    error = getaddrinfo(host, port_str, &hints, &strmSvr);
    if (error) {
      fprintf(stderr, "Could not resolve the host/port address: %s:%s\n", host,
        port_str);
      fprintf(stderr, "%s", gai_strerror(error));
      return FAIL;
    }

    // Create a reliable, stream socket using TCP
    atomic sock = socket(strmSvr->ai_family, strmSvr->ai_socktype, strmSvr->ai_protocol);
    if (sock == -1) {
      fprintf(stderr, "Could not create a socket.\n");
      fprintf(stderr, "%s\n", strerror(errno));
      return FAIL;
    }

    // Connect to the socket
    error = connect(sock, strmSvr->ai_addr, strmSvr->ai_addrlen);
    if (error == -1) {
      fprintf(stderr, "Could not connect to socket.\n");
      fprintf(stderr, "%s\n", strerror(errno));
      return FAIL;
    }

    freeaddrinfo(strmSvr);

    make_nonblocking(sock);

    call IO.registerFileDescriptor(sock);
    return SUCCESS;
  }

  command error_t TcpSocket.send (uint8_t* buf, uint16_t len) {
    ssize_t sent;

    if (sock == -1) {
      return FAIL;
    }

    while (1) {
      sent = send(sock, buf, len, 0);
      if (sent == -1) {
        ERROR("Error sending TCP socket. errno: %i\n", errno);
        ERROR("%s\n", strerror(errno));
        return FAIL;
      }

      if (sent == len) {
        break;
      } else if (sent > len) {
        ERROR("Error sent more than requested?");
        return FAIL;
      } else {
        len -= sent;
        buf += sent;
      }
    }
    return SUCCESS;
  }

  command error_t TcpSocket.close () {
    int result;

    if (sock == -1) return FAIL;

    result = close(sock);
    if (result == -1) {
      ERROR("Error closing TCP socket. errno: %i\n", errno);
      ERROR("%s\n", strerror(errno));
    }

    call IO.unregisterFileDescriptor(sock);
    sock = -1;

    return SUCCESS;
  }

  task void receive_task () {
    int len;

    atomic len = (int) msglen;

    signal TcpSocket.receive(msg, len);
  }

  task void reconnect_task () {
    reconnect();
  }

  async event void IO.receiveReady () {
    ssize_t recv_len;
    int local_sock;

    atomic local_sock = sock;

    recv_len = recv(local_sock, inbuf, INBUF_SIZE, 0);

    if (recv_len == -1) {
      switch (errno) {
        case EAGAIN:
          // Spurious wakeup
          return;
        default:
          ERROR("Error reading from TCP socket. errno: %i\n", errno);
          ERROR("%s\n", strerror(errno));
          exit(1);
      }
    } else if (recv_len == 0) {
      // Socket was closed
      post reconnect_task();
      return;
    }

    atomic msglen = recv_len;
    memcpy(msg, inbuf, recv_len);

    post receive_task();
  }

  default event void TcpSocket.receive (uint8_t* m, int mlen) {}

}
