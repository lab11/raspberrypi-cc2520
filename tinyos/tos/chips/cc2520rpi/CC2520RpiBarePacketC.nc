
configuration CC2520RpiBarePacketC {
  provides {
    interface Packet as BarePacket;
  }
  uses {
  	interface RadioPacket;
  }
}

implementation {
  components CC2520RpiBarePacketP;

  CC2520RpiBarePacketP.RadioPacket = RadioPacket;

  BarePacket = CC2520RpiBarePacketP.BarePacket;
}
