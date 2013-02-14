
// Handles all file descriptors

configuration IOManagerC {
  provides {
    interface IO[uint8_t id];
    interface BlockingIO;
  }
}

implementation {
  components IOManagerP;

  IO = IOManagerP.IO;
  BlockingIO = IOManagerP.BlockingIO;
}
