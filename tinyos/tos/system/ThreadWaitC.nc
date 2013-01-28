
configuration ThreadWaitC {
  provides {
    interface ThreadWait;
  }
}

implementation {
  components ThreadWaitP;
  components MainC;

  MainC.SoftwareInit -> ThreadWaitP.Init;

  ThreadWait = ThreadWaitP.ThreadWait;
}
