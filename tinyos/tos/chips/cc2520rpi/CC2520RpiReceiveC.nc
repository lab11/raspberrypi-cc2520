
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

  MainC.SoftwareInit -> ReceiveP.SoftwareInit;

  ReceiveP.PacketMetadata -> RadioP.PacketMetadata;
  ReceiveP.IO -> IOFileC.IO;

  BareReceive = ReceiveP.BareReceive;

}
