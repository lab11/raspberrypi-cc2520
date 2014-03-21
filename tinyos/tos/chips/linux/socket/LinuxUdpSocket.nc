
/* This is a simple TinyOS interface for a UDP socket. It exposes some
 * Linux-specific features, such as CORK'ing, that are useful.
 *
 * @author: Pat Pannuto <ppannuto@umich.edu>
 */

interface LinuxUdpSocket {

  // Open a socket to a remote server. host can be an ip address or a hostname.
  command error_t init (const char* host, uint16_t port);

  // Release any resources held by this socket. If the flush_buffer argument is
  // true, any partially constructed packet will be sent before closing the
  // socket, otherwise the data will be discarded. Any errors raised in sending
  // the final packet are silently discarded; if catching these are necessary,
  // callers should first sendData() instead.
  command error_t close (bool flush_buffer);

  // Build a single packet by appending data to each call of this function. No
  // data is actually sent until sendData() is called
  command error_t build_packet (uint8_t* buf, uint16_t len);

  // Send a packet. Any buffer provided here will be appended to the
  // buildPacket() buffer and then sent. buf may be NULL iff len is 0.
  // Sending a 0-length packet is not considered an error and will return
  // success.
  command error_t send_data (uint8_t* buf, uint16_t len);

  // No RX interface is currently provided.
}
