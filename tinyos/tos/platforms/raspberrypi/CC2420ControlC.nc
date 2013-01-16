
configuration CC2420ControlC {
  provides {
  	interface CC2420Config;
  }
}

implementation {
	components CC2420ControlP;
	components CC2520RpiRadioC;

	CC2420ControlP.RadioAddress -> CC2520RpiRadioC.RadioAddress;

	CC2420Config = CC2420ControlP.CC2420Config;
}
