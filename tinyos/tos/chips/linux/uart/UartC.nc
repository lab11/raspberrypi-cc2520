
configuration UartC {
  provides {
  	interface UartBuffer;
  }
}

implementation {
  components UartP;
  components MainC;
  components new IOFileC();

  MainC.SoftwareInit -> UartP.SoftwareInit;

  UartP.IO -> IOFileC.IO;

  UartBuffer = UartP.UartBuffer;
}

