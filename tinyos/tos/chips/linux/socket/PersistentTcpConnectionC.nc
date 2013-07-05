
/* Instantiate this component to create a TCP socket that will reconnect itself
 * if the connection is lost. This component basically wraps the linux socket
 * utilities into a nice TinyOS form.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

generic configuration PersistentTcpConnectionC () {
  provides {
    interface TcpSocket;
  }
}

implementation {
  components new PersistentTcpConnectionP() as TcpConnP;
  components new TimerMilliC() as ReconnectTimer;
  components new IOFileC() as IOF;

  TcpConnP.ReconnectTimer -> ReconnectTimer.Timer;
  TcpConnP.IO -> IOF.IO;

  TcpSocket = TcpConnP.TcpSocket;
}
