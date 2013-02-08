
configuration ReadLqiC {
  provides {
    interface ReadLqi;
  }
}

implementation {
  components ReadLqiP;
  components CC2520RpiRadioC;

  ReadLqiP.PacketMetadata -> CC2520RpiRadioC.PacketMetadata;

  ReadLqi = ReadLqiP.ReadLqi;
}
