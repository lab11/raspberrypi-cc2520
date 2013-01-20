
configuration CC2520RpiAmPacketC {
  provides {
    interface RadioPacket;
  }
}

implementation {

  components CC2520RpiAmPacketP as PacketP;

  RadioPacket = PacketP.RadioPacket;

}
