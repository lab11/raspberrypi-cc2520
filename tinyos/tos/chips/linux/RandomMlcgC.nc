
configuration RandomMlcgC {
  provides {
    interface Init;
    interface ParameterInit<uint16_t> as SeedInit;
    interface Random;
  }
}

implementation {
  components RandomMlcgP;

  Init = RandomMlcgP.Init;
  SeedInit = RandomMlcgP.SeedInit;
  Random = RandomMlcgP.Random;
}
