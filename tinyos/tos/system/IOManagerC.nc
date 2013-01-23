
// Handles all file descriptors

configuration IOManagerC {
  provides {
    interface IO[uint8_t io_id];
    interface BlockingIO;
  }
}

implementation {
  components IOManagerP;
  components TimerQueryC;

  IOManagerP.TimerQuery -> TimerQueryC.TimerQuery;

  IO = IOManagerP[uint8_t io_id];
  BlockingIO = IOManagerP.BlockingIO;
}
