
configuration ReadLqiC {
  provides {
    interface ReadLqi;
  }
}

implementation {
  components CC2420RadioC;
  ReadLqi = CC2420RadioC.ReadLqi;
}
