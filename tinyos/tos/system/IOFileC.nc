
generic configuration IOFileC () {
  provides {
    interface IO;
  }
}

implementation {
  components IOManagerC;

  IO = IOManagerC.IO[unique("FILEID")];
}
