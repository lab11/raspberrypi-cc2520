
configuration CC2520RpiSendC {
  provides {
    interface BareSend;
  }
}

implementation {
  components CC2520RpiSendP as SendP;
  components CC2520RpiRadioP as RadioP;
  components MainC;
  components new IOFileC();

  MainC.SoftwareInit -> SendP.SoftwareInit;

  SendP.PacketMetadata -> RadioP.PacketMetadata;
  SendP.IO -> IOFileC.IO;

  BareSend = SendP.BareSend;
}
