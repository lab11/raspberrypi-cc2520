
configuration ReadLqiC {
  provides {
    interface ReadLqi;
  }
}

implementation {
  components ReadLqiP;
  components RadioSelectC;

  ReadLqiP.PacketMetadata -> RadioSelectC.PacketMetadata;

  ReadLqi = ReadLqiP.ReadLqi;
}
