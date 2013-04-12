
configuration UnixTimeC {
  provides {
    interface UnixTime;
  }
}

implementation {
  components UnixTimeP;
  UnixTime = UnixTimeP.UnixTime;
}

