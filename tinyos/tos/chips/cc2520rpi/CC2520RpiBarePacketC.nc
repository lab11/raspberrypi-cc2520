
configuration CC2520RpiBarePacketC {
  provides {
    interface Packet as BarePacket;
  }
}

implementation {
  components CC2520RpiBarePacketP;
  components CC2520RpiPacketC;

  CC2520RpiBarePacketP.RadioPacket -> CC2520RpiPacketC.RadioPacket;

  BarePacket = CC2520RpiBarePacketP.BarePacket;
}
