
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

  // Choose the addressing scheme
  // This is still not ideal, but will work for now.
//  components StaticIPAddressC;
//  components StaticIPAddressTosIdC;
//  components Dhcp6C;


#ifdef RPL_ROUTING
  components RPLRoutingC;
  App.RootControl -> RPLRoutingC.RootControl;
#endif

  components UDPShellC;
}
