
configuration CC2520RpiSendC {
  provides {
    interface BareSend;
  }
}

implementation {

  components CC2520RpiSendP as SendP;
  components MainC;

  MainC.SoftwareInit -> SendP.SoftwareInit;

  BareSend = SendP.BareSend;

  //experimenting
  components new TimerMilliC();
  SendP.Timer -> TimerMilliC;

}



