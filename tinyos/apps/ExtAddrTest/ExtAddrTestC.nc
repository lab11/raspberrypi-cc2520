
configuration ExtAddrTestC { }

implementation {
  components ExtAddrTestP;
  components CC2420RadioC as MessageC;
  components MainC;
  components new TimerMilliC();
  components LedsC;

  ExtAddrTestP.Boot -> MainC;
  ExtAddrTestP.Timer0 -> TimerMilliC;
  ExtAddrTestP.Leds -> LedsC;

  ExtAddrTestP.RadioControl -> MessageC.SplitControl;

  ExtAddrTestP.BarePacket -> MessageC.BarePacket;
  ExtAddrTestP.Ieee154Send -> MessageC.BareSend;
  ExtAddrTestP.Ieee154Receive -> MessageC.BareReceive;
  ExtAddrTestP.PacketLink -> MessageC.PacketLink;
}

