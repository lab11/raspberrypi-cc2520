
interface IO {
  // Add a file descriptor to the select() call
  command error_t registerFileDescriptor (int file_descriptor);

  // Event that is triggered when data is ready on this io file
  async event void receiveReady ();
}
