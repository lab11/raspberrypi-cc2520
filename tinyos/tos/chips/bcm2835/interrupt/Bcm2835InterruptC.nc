
configuration Bcm2835InterruptC {
  provides {
    interface GpioInterrupt as Port1_10;
  }
}

implementation {
  components Bcm2835InterruptP as IntP;
  components PlatformP;

  PlatformP.InterruptInit -> IntP.Init;

  Port1_10 = IntP.Port1_10;
}

