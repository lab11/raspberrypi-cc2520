
configuration CC2520RpiLinkC {
  provides {
    interface BareSend as Send;
  }
  uses {
    interface BareSend as SubSend;
  }
}

implementation {
  components CC2520RpiLinkP as LinkP;
  components CC2520RpiRadioBareC;
  components new TimerMilliC();

  SubSend = LinkP.SubSend;
  LinkP.PacketMetadata -> CC2520RpiRadioBareC.PacketMetadata;
  LinkP.DelayTimer -> TimerMilliC;

  Send = LinkP.Send;
}
