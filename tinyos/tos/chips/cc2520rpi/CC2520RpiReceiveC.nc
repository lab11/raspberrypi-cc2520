
configuration CC2520RpiReceiveC {
  provides {
    interface BareReceive;
  }
}

implementation {

  components CC2520RpiReceiveP as ReceiveP;
  components CC2520RpiRadioC as RadioC;
  components MainC;

  MainC.SoftwareInit -> ReceiveP.SoftwareInit;

  ReceiveP.PacketMetadata -> RadioC.PacketMetadata;

  BareReceive = ReceiveP.BareReceive;

}
