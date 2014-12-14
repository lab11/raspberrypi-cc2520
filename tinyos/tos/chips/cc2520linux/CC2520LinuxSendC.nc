
generic configuration CC2520LinuxSendC (const char* char_dev_path) {
  provides {
    interface BareSend;
  }
  uses {
    interface PacketMetadata;
  }
}

implementation {
  components MainC;

  components new CC2520LinuxSendP(char_dev_path) as SendP;
  components new IOFileC();

  MainC.SoftwareInit -> SendP.SoftwareInit;

  SendP.IO -> IOFileC.IO;
  SendP.PacketMetadata = PacketMetadata;

  BareSend = SendP.BareSend;
}
