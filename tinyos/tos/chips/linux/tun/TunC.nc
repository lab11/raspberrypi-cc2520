
configuration TunC {
  provides {
    interface IPForward;
  }
}

implementation {
  components TunP;
  components MainC;
  components new IOFileC();

  TunP.IO -> IOFileC.IO;

  MainC.SoftwareInit -> TunP.SoftwareInit;

  IPForward = TunP.IPForward;
}
