#include "RadioCountToLedsBlip.h"

configuration RadioCountToLedsBlipC {}
implementation {
  components MainC, RadioCountToLedsBlipP as App, LedsC;
  components new TimerMilliC();

  App.Boot -> MainC.Boot;

  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;


  // Radio
  components IPStackC;
  components new UdpSocketC() as UDPService;
  App.RadioControl -> IPStackC;
  App.UDPService   -> UDPService;

  components BorderC;
}


