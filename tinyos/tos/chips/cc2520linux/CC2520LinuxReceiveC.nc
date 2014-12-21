/*
 * Packet receive path for the CC2520
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

generic configuration CC2520LinuxReceiveC (char char_dev_path[]) {
  provides {
    interface BareReceive;
  }
  uses {
    interface PacketMetadata;
  }
}

implementation {

  components MainC;

  components new CC2520LinuxReceiveP(char_dev_path) as ReceiveP;
  components new IOFileC();
  components UnixTimeC;

  MainC.SoftwareInit -> ReceiveP.SoftwareInit;

  ReceiveP.IO -> IOFileC.IO;
  ReceiveP.UnixTime -> UnixTimeC.UnixTime;

  ReceiveP.PacketMetadata = PacketMetadata;

  BareReceive = ReceiveP.BareReceive;

}
