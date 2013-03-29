
configuration Bcm2835InterruptC {
  provides {
    interface GpioInterrupt as Port1_10;
  }
}

implementation {
  components Bcm2835InterruptP as IntP;
  components MainC;

  MainC.SoftwareInit -> IntP.SoftwareInit;

  Port1_10 = IntP.Port1_10;
}

