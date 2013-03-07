
configuration CC2520RpiReceiveC {
  provides {
    interface BareReceive;
  }
}

implementation {

  components CC2520RpiReceiveP as ReceiveP;
  components CC2520RpiRadioP as RadioP;
  components MainC;
  components new IOFileC();
  components UnixTimeC;

  MainC.SoftwareInit -> ReceiveP.SoftwareInit;

  ReceiveP.PacketMetadata -> RadioP.PacketMetadata;
  ReceiveP.IO -> IOFileC.IO;
  ReceiveP.UnixTime -> UnixTimeC.UnixTime;

  BareReceive = ReceiveP.BareReceive;

}
