
/* Provides an easy way to read from the serial port /dev/ttyAMA0 on the RPi.
 * Be sure to check that the serial port isn't being used by the kernel, etc.
 * if you get errors.
 */

configuration UartC {
  provides {
    interface UartBuffer;
  }
}

implementation {
  components UartP;
  components MainC;
  components new IOFileC();
  components UnixTimeC;

  MainC.SoftwareInit -> UartP.SoftwareInit;

  UartP.IO -> IOFileC.IO;
  UartP.UnixTime -> UnixTimeC.UnixTime;

  UartBuffer = UartP.UartBuffer;
}
