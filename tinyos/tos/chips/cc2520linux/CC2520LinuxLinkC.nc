
generic configuration CC2520LinuxLinkC () {
  provides {
    interface BareSend as Send;
  }
  uses {
    interface BareSend as SubSend;
    interface PacketMetadata;
  }
}

implementation {
  components new CC2520RpiLinkP() as LinkP;
  components new TimerMilliC();

  LinkP.DelayTimer -> TimerMilliC;

  LinkP.SubSend = SubSend;
  LinkP.PacketMetadata = PacketMetadata;

  Send = LinkP.Send;
}
