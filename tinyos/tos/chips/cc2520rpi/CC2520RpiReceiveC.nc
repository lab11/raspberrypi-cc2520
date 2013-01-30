
configuration CC2520RpiReceiveC {
  provides {
    interface BareReceive;
  }
}

implementation {

  components CC2520RpiReceiveP as ReceiveP;
  components CC2520RpiRadioP as RadioP;
  components MainC;

  MainC.SoftwareInit -> ReceiveP.SoftwareInit;

  ReceiveP.PacketMetadata -> RadioP.PacketMetadata;

  BareReceive = ReceiveP.BareReceive;

}
