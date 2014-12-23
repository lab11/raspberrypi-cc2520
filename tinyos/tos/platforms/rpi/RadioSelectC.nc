/* Use this module to choose which radio on RPi to use.
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

  components new CC2520LinuxRadioC("/dev/radio") as RadioC;

  SplitControl      = RadioC.SplitControl;
  Send              = RadioC.Send;
  Receive           = RadioC.Receive;
  Packet            = RadioC.Packet;
  LowPowerListening = RadioC.LowPowerListening;
  PacketMetadata    = RadioC.PacketMetadata;
  Ieee154Address    = RadioC.Ieee154Address;
}

