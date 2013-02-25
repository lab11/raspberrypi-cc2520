
configuration BusyWaitMicroC {
  provides {
  	interface BusyWait<TMicro, uint16_t>;
  }
}
implementation {
  components BusyWaitMicroP;

  BusyWait = BusyWaitMicroP.BusyWait;
}
