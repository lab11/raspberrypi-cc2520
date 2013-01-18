
configuration TunC {
  provides {
    interface IPForward;
  }
}

implementation {
  components TunP;

  IPForward = TunP.IPForward;
}
