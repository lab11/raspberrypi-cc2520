
configuration CC2520RpiAmUniqueC {
  provides {
    interface BareSend as Send;
  }
  uses {
    interface BareSend as SubSend;
  }
}

implementation {
  components CC2520RpiAmUniqueP;
  components MainC;

  MainC.SoftwareInit -> CC2520RpiAmUniqueP.Init;

  Send = CC2520RpiAmUniqueP.Send;
  SubSend = CC2520RpiAmUniqueP.SubSend;
}
