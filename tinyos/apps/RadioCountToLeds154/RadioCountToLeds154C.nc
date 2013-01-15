#include "RadioCountToLeds154.h"

/**
 * Configuration for the RadioCountToLeds application. RadioCountToLeds
 * maintains a 4Hz counter, broadcasting its value in an AM packet
 * every time it gets updated. A RadioCountToLeds node that hears a counter
 * displays the bottom three bits on its LEDs. This application is a useful
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @author Brad Campbell (change to use Ieee154 interfaces)
 * @date   June 6 2005
 */

configuration RadioCountToLeds154C {}
implementation {
  components MainC, RadioCountToLeds154P as App, LedsC;
 // components new AMSenderC(AM_RADIO_COUNT_MSG);
 // components new AMReceiverC(AM_RADIO_COUNT_MSG);
  components Ieee154MessageC;
  components new TimerMilliC();
//  components ActiveMessageC;

  App.Boot -> MainC.Boot;

  App.Receive -> Ieee154MessageC.Ieee154Receive;
  App.Ieee154Send -> Ieee154MessageC.Ieee154Send;
  App.RadioControl -> Ieee154MessageC.SplitControl;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  App.Ieee154Packet -> Ieee154MessageC.Packet;
}


