
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

