
configuration TunC {
  provides {
    interface IPForward;
  }
}

implementation {
  components TunP;
  components MainC;

  MainC.SoftwareInit -> TunP.SoftwareInit;

  IPForward = TunP.IPForward;
}
