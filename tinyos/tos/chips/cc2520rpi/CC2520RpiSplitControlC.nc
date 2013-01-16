
configuration CC2520RpiSplitControlC {
  provides {
    interface SplitControl;
  }
}

implementation {
  components CC2520RpiSplitControlP;

  SplitControl = CC2520RpiSplitControlP.SplitControl;
}
