
configuration ReadLqiC {
  provides {
    interface ReadLqi;
  }
}

implementation {
  components ReadLqiP;
  components CC2520RpiRadioBareC;

  ReadLqiP.PacketMetadata -> CC2520RpiRadioBareC.PacketMetadata;

  ReadLqi = ReadLqiP.ReadLqi;
}
