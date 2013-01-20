
configuration CC2520RpiPacketAcknowledgementsC {
  provides {
    interface PacketAcknowledgements;
  }
}

implementation {

  components CC2520RpiPacketAcknowledgementsP as AckP;
  components MainC;

  PacketAcknowledgements = AckP.PacketAcknowledgements;

}
