
configuration ReadLqiC {
  provides {
    interface ReadLqi;
  }
}

implementation {
  components ReadLqiP;
  components CC2520RpiRadioC;

  ReadLqiP.PacketLinkQuality -> CC2520RpiRadioC.PacketLinkQuality;
  ReadLqiP.PacketRSSI -> CC2520RpiRadioC.PacketRSSI;

  ReadLqi = ReadLqiP.ReadLqi;
}
