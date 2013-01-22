
configuration BorderRouterC {}
implementation {
  components MainC;
  components BorderRouterP as App;
  components LedsC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC;

  // Radio/IP
  components IPStackC;
  App.RadioControl -> IPStackC;

  components BorderC;

#ifdef RPL_ROUTING
  components RPLRoutingC;
  App.RootControl -> RPLRoutingC.RootControl;
#endif

  components UDPShellC;
}


