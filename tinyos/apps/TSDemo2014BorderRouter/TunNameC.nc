/* Provide the name of the TUN interface.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration TunNameC {
  provides {
    interface TunName;
  }
}

implementation {
  components TunNameP;
  components CommandLineC;

  TunNameP.CommandLineArgs -> CommandLineC.CommandLineArgs;

  TunName = TunNameP.TunName;
}
