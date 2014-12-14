
configuration ReadLqiC {
  provides {
    interface ReadLqi;
  }
}

implementation {
  components ReadLqiP;
  components CC2520LinuxRadioC;

  ReadLqiP.PacketMetadata -> CC2520LinuxRadioC.PacketMetadata;

  ReadLqi = ReadLqiP.ReadLqi;
}
