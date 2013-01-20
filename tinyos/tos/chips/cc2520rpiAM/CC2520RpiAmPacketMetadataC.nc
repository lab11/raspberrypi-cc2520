
configuration CC2520RpiAmPacketMetadataC {
  provides {
    interface PacketField<uint8_t> as PacketLinkQuality;
    interface PacketField<uint8_t> as PacketRSSI;
  }
}

implementation {
  components CC2520RpiAmPacketMetadataP;
  components CC2520RpiRadioC;

  CC2520RpiAmPacketMetadataP.PacketMetadata -> CC2520RpiRadioC.PacketMetadata;

  PacketLinkQuality = CC2520RpiAmPacketMetadataP.PacketLinkQuality;
  PacketRSSI = CC2520RpiAmPacketMetadataP.PacketRSSI;
}
