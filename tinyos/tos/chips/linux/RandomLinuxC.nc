
/* TinyOS interface for Random provided by the Linux random utilities.
 * Unfortunately the RandomC interface is wired to a particular random
 * number generator so if you want to use the Linux random you have to wire
 * to it explicitly. Boo TinyOS.
 */

configuration RandomLinuxC {
  provides {
    interface Init;
    interface ParameterInit<uint16_t> as SeedInit;
    interface Random;
  }
}

implementation {
  components RandomLinuxP as Rand;

  Init = Rand.Init;
  SeedInit = Rand.SeedInit;
  Random = Rand.Random;
}
