
configuration BorderC {
}

implementation {
  components TunC;

  components IPForwardingEngineP;
  IPForwardingEngineP.IPForward[10] -> TunC.IPForward;
}
