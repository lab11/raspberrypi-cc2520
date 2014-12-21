
/* Basic component includes for a general purpose border router.
 *
 * @author Brad Campbell <bradjc@umich.edu>
 */

configuration BorderRouterC {}
implementation {
  components MainC;
  components BorderRouterP as App;

  App.Boot -> MainC.Boot;

  // Radio/IP
  components IPStackC;
  App.RadioControl -> IPStackC;

  components BorderC;

  // If we want to use static addressing
  components StaticIPAddressC;


  // Uncomment to use DHCP
//  components Dhcp6C;


#ifdef RPL_ROUTING
  components RPLRoutingC;
  App.RootControl -> RPLRoutingC.RootControl;
#endif

  components UDPShellC;
}
