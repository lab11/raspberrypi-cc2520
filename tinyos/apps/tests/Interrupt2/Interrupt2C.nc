
/* Simple app to receive an interrupt and toggle an led.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration Interrupt2C {
}

implementation {
  components Interrupt2P as InterruptP;
  components MainC;
  components LedsC;

  components Bcm2835InterruptC;
  components new TimerMilliC();

  InterruptP.Int -> Bcm2835InterruptC.Port1_26;
  InterruptP.Boot -> MainC.Boot;
  InterruptP.TimerMilliC -> TimerMilliC;

  InterruptP.Leds -> LedsC;

  components HplBcm2835GeneralIOC as HplGpioC;
  InterruptP.Pin -> HplGpioC.Port1_26;

}
