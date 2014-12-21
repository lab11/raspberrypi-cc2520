/* Use this module to choose which radio on GAP to use.
 */
configuration RadioSelectC {
  provides {
    interface SplitControl;

    interface Send;
    interface Receive;
    interface Packet;
    interface LowPowerListening;
    interface PacketMetadata;
    interface Ieee154Address;
  }
}

implementation {

#if GAP_RADIO_SELECT == 0
  components new CC2520LinuxRadioC("/dev/cc2520_0") as RadioC;
#elif GAP_RADIO_SELECT == 1
  components new CC2520LinuxRadioC("/dev/cc2520_1") as RadioC;
#endif

  SplitControl      = RadioC.SplitControl;
  Send              = RadioC.Send;
  Receive           = RadioC.Receive;
  Packet            = RadioC.Packet;
  LowPowerListening = RadioC.LowPowerListening;
  PacketMetadata    = RadioC.PacketMetadata;
  Ieee154Address    = RadioC.Ieee154Address;
}

