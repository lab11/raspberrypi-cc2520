
/* Simple interface to provide unix timestamps.
 */

configuration UnixTimeC {
  provides {
    interface UnixTime;
  }
}

implementation {
  components UnixTimeP;
  UnixTime = UnixTimeP.UnixTime;
}

