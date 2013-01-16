
configuration CC2420ControlC {
  provides {
  	interface CC2420Config;
  }
}

implementation {
	components CC2420ControlP;
	components CC2520RadioC;

	CC2420ControlP.RadioAddress -> CC2520RadioC.RadioAddress;

	CC2420Config = CC2420ControlP.CC2420Config;
}
