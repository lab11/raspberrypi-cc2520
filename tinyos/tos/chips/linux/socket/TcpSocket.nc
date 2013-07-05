
/* This is a simple TinyOS interface for a TCP socket.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

interface TcpSocket {

  // Open a socket to a remote server. host can be an ip address or a hostname.
  command error_t connect (const char* host, uint16_t port);

  // Send a buffer to the remove host. This function will loop until all of the
  // data is sent.
  command error_t send (uint8_t* buf, uint16_t len);

  // Close the connection to the server.
  command error_t close ();

  // Callback when data comes in on the socket.
  event void receive(uint8_t* msg, int msglen);

}
