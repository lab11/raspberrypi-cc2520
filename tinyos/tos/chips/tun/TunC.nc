
configuration TunC {
  provides {
    interface IPForward;
  }
}

implementation {
  components TunP;
  components MainC;
  components ThreadWaitC;

  MainC.SoftwareInit -> TunP.SoftwareInit;
  TunP.ThreadWait -> ThreadWaitC.ThreadWait;

  IPForward = TunP.IPForward;
}
