
configuration CC2520RpiReceiveC {
  provides {
    interface BareReceive;
  }
}

implementation {

  components CC2520RpiReceiveP as ReceiveP;
  components MainC;

  MainC.SoftwareInit -> ReceiveP.SoftwareInit;

  BareReceive = ReceiveP.BareReceive;

}



