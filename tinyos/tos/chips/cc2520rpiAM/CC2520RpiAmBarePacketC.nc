
configuration CC2520RpiAmBarePacketC {
  provides {
    interface Packet as BarePacket;
  }
  uses {
  	interface RadioPacket;
  }
}

implementation {
  components CC2520RpiAmBarePacketP;

  CC2520RpiAmBarePacketP.RadioPacket = RadioPacket;

  BarePacket = CC2520RpiAmBarePacketP.BarePacket;
}
