
configuration InterruptC {
}

implementation {
  components InterruptP;
  components MainC;
  components LedsC;

  components Bcm2835InterruptC;
  components new TimerMilliC();

  InterruptP.Int -> Bcm2835InterruptC.Port1_08;
  InterruptP.Boot -> MainC.Boot;
  InterruptP.TimerMilliC -> TimerMilliC;

  InterruptP.Leds -> LedsC;

}
