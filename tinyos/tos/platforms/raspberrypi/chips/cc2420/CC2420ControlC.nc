
configuration CC2420ControlC {
  provides {
  	interface CC2420Config;
  }
}

implementation {
	components CC2420RadioC;
	CC2420Config = CC2420RadioC.CC2420Config;
}
