
/* File based implementation of Linux userspace interrupts.
 * Unfortunately because this module works by letting the kernel module write
 * to a file with information about interrupts, there is about a 2ms delay
 * between the interrupt being triggered and the TinyOS app registering it.
 * This means this module cannot be used for anything that requires tight
 * timing.
 */

configuration Bcm2835InterruptC {
  provides {
    interface GpioInterrupt as Port1_03;
    interface GpioInterrupt as Port1_08;
    interface GpioInterrupt as Port1_10;
    interface GpioInterrupt as Port1_12;
    interface GpioInterrupt as Port1_13;
    interface GpioInterrupt as Port1_19;
    interface GpioInterrupt as Port1_21;
    interface GpioInterrupt as Port1_23;
    interface GpioInterrupt as Port1_24;
    interface GpioInterrupt as Port1_26;
  }
}

implementation {
  components Bcm2835InterruptP as IntP;
  components PlatformP;

  PlatformP.InterruptInit -> IntP.Init;

  Port1_03 = IntP.Port1[2];
  Port1_08 = IntP.Port1[14];
  Port1_10 = IntP.Port1[15];
  Port1_12 = IntP.Port1[18];
  Port1_13 = IntP.Port1[27];
  Port1_19 = IntP.Port1[10];
  Port1_21 = IntP.Port1[9];
  Port1_23 = IntP.Port1[11];
  Port1_24 = IntP.Port1[8];
  Port1_26 = IntP.Port1[7];
}
