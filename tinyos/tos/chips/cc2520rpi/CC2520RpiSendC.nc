
configuration CC2520RpiSendC {
  provides {
    interface BareSend;
  }
}

implementation {
  components CC2520RpiSendP as SendP;
  components CC2520RpiRadioP as RadioP;
  components MainC;
  components ThreadWaitC;

  MainC.SoftwareInit -> SendP.SoftwareInit;

  SendP.PacketMetadata -> RadioP.PacketMetadata;
  SendP.ThreadWait -> ThreadWaitC.ThreadWait;

  BareSend = SendP.BareSend;
}
