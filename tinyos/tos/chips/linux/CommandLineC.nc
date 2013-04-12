
/* Provides an interface to retreive the command line arguments from the
 * start of the application. Behaves very similarly to the argc/argv
 * arguments to int main().
 */

configuration CommandLineC {
  provides {
    interface CommandLineArgs;
  }
}

implementation {
  components CommandLineP;
  components MainC;

  MainC.SoftwareInit -> CommandLineP.SoftwareInit;

  CommandLineArgs = CommandLineP;
}
