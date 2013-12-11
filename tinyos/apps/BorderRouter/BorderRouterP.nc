
module BorderRouterP @safe() {
  uses {
    interface Boot;

    interface SplitControl as RadioControl;
    interface RootControl;
  }
}
implementation {

  event void Boot.booted() {
#ifdef RPL_ROUTING
    call RootControl.setRoot();
#endif
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call RadioControl.start();
    }
  }

  event void RadioControl.stopDone (error_t e) { }

}
