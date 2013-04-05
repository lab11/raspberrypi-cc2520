
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
