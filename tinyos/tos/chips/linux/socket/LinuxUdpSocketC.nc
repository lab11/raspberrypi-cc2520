
/* Instantiate this component to create a TCP socket that will reconnect itself
 * if the connection is lost. This component basically wraps the linux socket
 * utilities into a nice TinyOS form.
 *
 * @author: Pat Pannuto <ppannuto@umich.edu>
 */

generic configuration LinuxUdpSocketC () {
  provides {
    interface LinuxUdpSocket;
  }
}

implementation {
  components new LinuxUdpSocketP();
  LinuxUdpSocket = LinuxUdpSocketP.LinuxUdpSocket;
}
