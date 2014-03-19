/* Get the TUN name from the command line options
 *
 * @author Brad Campbell <bradjc@umich.edu>
 */

module TunNameP {
  provides {
    interface TunName;
  }
  uses {
    interface CommandLineArgs;
  }
}

implementation {

  command char* TunName.getTunName () {
    uint8_t argc;
    uint8_t i;

    argc = call CommandLineArgs.count();

    // Iterate through the arguments, skipping the name of the executable
    for (i=1; i<argc; i++) {
      char* arg = call CommandLineArgs.getArg(i);

      if (strncmp(arg, "-i", 2) == 0) {
        // found -i, now see what the interface name is
        if (argc > i+1) {
          return call CommandLineArgs.getArg(i+1);
        }
      }
    }

    return "\0";
  }

}
