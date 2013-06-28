configuration HplDs2411C {
  provides {
    interface GeneralIO as Gpio;
  }
}
implementation {
  components HplBcm2835GeneralIOC as Hpl;
  components new Bcm2835GpioC() as BcmGpio;
  BcmGpio.IO -> Hpl.Port1_08;

  Gpio = BcmGpio.GeneralIO;
}
