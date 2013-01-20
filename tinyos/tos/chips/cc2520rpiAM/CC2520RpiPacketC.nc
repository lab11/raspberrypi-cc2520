
configuration CC2520RpiPacketC {
  provides {
    interface RadioPacket;
  }
}

implementation {

  components CC2520RpiPacketP as PacketP;

  RadioPacket = PacketP.RadioPacket;

}
