#include <Timer.h>
#include "SimpleSackTest.h"

configuration SimpleSackTestAppC {
}
implementation {
  components MainC;
  components LedsC;
  components SimpleSackTestC as App;
  components new TimerMilliC() as Timer0;
  
  components CC2420Ieee154MessageC as RadioC;

  App.Ieee154Send -> RadioC.Ieee154Send;
  App.Ieee154Receive -> RadioC.Ieee154Receive;
  App.Ieee154Packet -> RadioC.Ieee154Packet;
  App.RadioControl -> RadioC.SplitControl;
  App.Packet -> RadioC.Packet;
  App.PacketAcknowledgements -> RadioC.PacketAcknowledgements;
  App.CC2420Config -> RadioC.CC2420Config;
  
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
}
